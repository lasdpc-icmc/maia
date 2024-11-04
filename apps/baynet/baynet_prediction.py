import pandas as pd
import redis, os
from pgmpy.models import BayesianNetwork
from pgmpy.factors.discrete import TabularCPD
from pgmpy.inference import VariableElimination


REDIS = os.environ["REDIS_URL"]

# Load service relationships
relations_df = pd.read_csv('traces/service_relations.csv')
relations_df.columns = ['Source', 'Destination']

# Load service health scores
scores_df = pd.read_csv('traces/service_scores.csv')
scores_df.columns = ['istio.canonical_service', 'score']

average_scores_df = scores_df.groupby('istio.canonical_service').mean().reset_index()

model = BayesianNetwork()

services_with_scores = set(average_scores_df['istio.canonical_service'])

# Add edges based on service relationships only for services with scores
for _, row in relations_df.iterrows():
    source = row['Source']
    destination = row['Destination']
    
    if source in services_with_scores and destination in services_with_scores:
        model.add_edge(source, destination)

# Define CPDs (Conditional Probability Distributions) for each service with an average score
for service in services_with_scores:
    avg_score = average_scores_df[average_scores_df['istio.canonical_service'] == service]['score'].values[0]

    if len(model.get_parents(service)) == 0:
        cpd = TabularCPD(variable=service, variable_card=2, 
                         values=[[1 - avg_score], [avg_score]])  # Unhealthy, Healthy
    
    # If the service has parents, use conditional probabilities based on the average score
    else:
        parent_count = len(model.get_parents(service))
        # The probability of being "Healthy" for each parent configuration
        values = [[1 - avg_score] * 2**parent_count, [avg_score] * 2**parent_count]
        cpd = TabularCPD(variable=service, variable_card=2, values=values,
                         evidence=model.get_parents(service),
                         evidence_card=[2] * parent_count)
    
    model.add_cpds(cpd)

# Validate the model structure
try:
    assert model.check_model(), "Model structure is invalid"
except Exception as e:
    print(f"Model check error: {e}")

inference = VariableElimination(model)

probabilities = {}

# Example inference: Check the probability of each service being down (0) and up (1)
for service in services_with_scores:
    if service in model.nodes():
        prob = inference.query(variables=[service])
        probabilities[service] = prob.values[0]  # Probability of being down (index 0)

probabilities_df = pd.DataFrame(list(probabilities.items()), columns=['istio.canonical_service', 'down_probability'])

probabilities_df.to_csv('traces/service_down_probabilities.csv', index=False)

redis_client = redis.Redis(host=REDIS, port=6379, db=0)

for index, row in probabilities_df.iterrows():
    key = f"down_probability:{row['istio.canonical_service']}"  # Updated key pattern
    redis_client.set(key, row['down_probability'])

print("Service down probabilities saved to 'traces/service_down_probabilities.csv' and stored in Redis.")

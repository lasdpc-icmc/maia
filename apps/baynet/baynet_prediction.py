import pandas as pd
from pgmpy.models import BayesianNetwork
from pgmpy.factors.discrete import TabularCPD
from pgmpy.estimators import MaximumLikelihoodEstimator
from pgmpy.inference import VariableElimination

data = pd.DataFrame({
    'MicroserviceA': [0, 1, 1, 0, 0, 1, 1, 0, 0, 1],
    'MicroserviceB': [1, 1, 0, 0, 0, 1, 1, 0, 0, 1],
    'MicroserviceC': [0, 0, 1, 0, 0, 1, 1, 0, 0, 1],
    'Incident': [1, 1, 0, 0, 0, 1, 1, 0, 0, 1]
})

model = BayesianNetwork([('MicroserviceA', 'Incident'), 
                         ('MicroserviceB', 'Incident'),
                         ('MicroserviceC', 'Incident')])

model.fit(data, estimator=MaximumLikelihoodEstimator)

infer = VariableElimination(model)
result = infer.map_query(variables=['MicroserviceA', 'MicroserviceB', 'MicroserviceC'], evidence={'Incident': 1})
print(result)

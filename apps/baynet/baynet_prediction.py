import pandas as pd
import networkx as nx
from sklearn.preprocessing import LabelEncoder
from causalnex.network import BayesianNetwork
from causalnex.structure import StructureModel
from causalnex.structure.notears import from_pandas
import seaborn as sns
import matplotlib.pyplot as plt
from causalnex.plots import plot_structure, NODE_STYLE, EDGE_STYLE

def read_service_relations(filename):
    relations = []
    df_relations = pd.read_csv(filename)
    for _, row in df_relations.iterrows():
        source = row['Source'].strip()
        destination = row['Destination'].strip()
        if source and destination:
            relations.append((source, destination))
    return relations

df_traces = pd.read_csv('traces/preprocessed_traces.csv')

relations = read_service_relations('traces/service_relations.csv')
sm = StructureModel()
for source, destination in relations:
    sm.add_edge(source, destination)

print("Nodes in the Bayesian Network:")
print(sm.nodes)
print("Edges in the Bayesian Network:")
print(sm.edges)

if nx.number_weakly_connected_components(sm) > 1:
    largest_cc = max(nx.weakly_connected_components(sm), key=len)
    nodes_to_connect = set(sm.nodes) - largest_cc
    for node in nodes_to_connect:
        sm.add_edge(node, next(iter(largest_cc)))

viz = plot_structure(
    sm,
    all_node_attributes=NODE_STYLE.WEAK,
    all_edge_attributes=EDGE_STYLE.WEAK,
)
viz.show('structure_plot.html')


columns_of_interest = [
    'spanID', 'startTime', 'durationNanos',
    'istio.canonical_service', 'request_size', 'node_id',
    'http.status_code', 'downstream_cluster', 'response_size',
    'response_flags', 'net.host.ip', 'istio.canonical_revision',
    'http.method', 'http.url', 'istio.mesh_id', 'peer.address',
    'user_agent', 'component', 'zone', 'istio.namespace',
    'upstream_cluster', 'guid:x-request-id', 'istio.cluster_id',
    'http.protocol', 'upstream_cluster.name'
]
df_filtered = df_traces[columns_of_interest].fillna('unknown')

missing_nodes = set(sm.nodes) - set(df_filtered['istio.canonical_service'].unique())
if missing_nodes:
    print(f"Warning: The following nodes are missing in the dataset: {missing_nodes}")

label_encoders = {}
for column in df_filtered.select_dtypes(include=['object']).columns:
    le = LabelEncoder()
    df_filtered[column] = le.fit_transform(df_filtered[column])
    label_encoders[column] = le

common_nodes = list(set(sm.nodes).intersection(df_filtered.columns))
df_filtered_common = df_filtered[common_nodes]

bn = BayesianNetwork(sm)

try:
    bn = bn.fit_node_states_and_cpds(df_filtered_common)
except Exception as e:
    print(f"Error fitting the Bayesian Network: {e}")

node_of_interest = 'istio.canonical_service'
if node_of_interest in df_filtered_common.columns:
    predictions = bn.predict_probability(df_filtered_common, node=node_of_interest)
    print(predictions.head())

    df_filtered_common['predicted_service_status'] = predictions.idxmax(axis=1)
    df_filtered_common['predicted_service_status'] = df_filtered_common['predicted_service_status'].apply(
        lambda x: label_encoders[node_of_interest].inverse_transform([int(x.split('_')[-1])])[0]
    )

    df_filtered_common['actual_service_status'] = df_filtered_common[node_of_interest].apply(
        lambda x: label_encoders[node_of_interest].inverse_transform([x])[0]
    )

    print(df_filtered_common[['actual_service_status', 'predicted_service_status']].head())

    mis_predictions = df_filtered_common[df_filtered_common['actual_service_status'] != df_filtered_common['predicted_service_status']]
    print("Potential issues (mispredictions):")
    print(mis_predictions[['actual_service_status', 'predicted_service_status']])
else:
    print(f"Node of interest '{node_of_interest}' is not present in the dataset.")

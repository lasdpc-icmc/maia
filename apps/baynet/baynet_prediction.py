import pandas as pd
from sklearn.preprocessing import LabelEncoder
from causalnex.structure.notears import from_pandas
from causalnex.network import BayesianNetwork
from causalnex.structure import StructureModel
import networkx as nx
from causalnex.plots import plot_structure, NODE_STYLE, EDGE_STYLE
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('traces/preprocessed_traces.csv')

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
df_filtered = df[columns_of_interest]
df_filtered = df_filtered.fillna('unknown')

label_encoders = {}
for column in df_filtered.select_dtypes(include=['object']).columns:
    le = LabelEncoder()
    df_filtered[column] = le.fit_transform(df_filtered[column])
    label_encoders[column] = le

plt.figure(figsize=(10, 6))
sns.countplot(y='istio.canonical_service', data=df)
plt.title('Distribution of istio.canonical_service')
plt.show()

sm = from_pandas(df_filtered)

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

bn = BayesianNetwork(sm)
bn = bn.fit_node_states_and_cpds(df_filtered)

node_of_interest = 'istio.canonical_service'
predictions = bn.predict_probability(df_filtered, node=node_of_interest)
print(predictions.head())

df_filtered['predicted_service_status'] = predictions.idxmax(axis=1)

df_filtered['predicted_service_status'] = df_filtered['predicted_service_status'].apply(
    lambda x: label_encoders[node_of_interest].inverse_transform([int(x.split('_')[-1])])[0]
)

df_filtered['actual_service_status'] = df_filtered[node_of_interest].apply(
    lambda x: label_encoders[node_of_interest].inverse_transform([x])[0]
)

print(df_filtered[['actual_service_status', 'predicted_service_status']].head())

mis_predictions = df_filtered[df_filtered['actual_service_status'] != df_filtered['predicted_service_status']]
print("Potential issues (mispredictions):")
print(mis_predictions[['actual_service_status', 'predicted_service_status']])
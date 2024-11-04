import flask
import requests
import waitress
import os
import pandas as pd

app = flask.Flask('nodegraph-generator')

def load_outage_data(file_path):
    '''
    Load outage data from a CSV file into a dictionary.
    '''
    
# Load outage data from CSV
    outage_data = pd.read_csv('traces/data.csv')  # Update the path to your CSV file
    outage_map = dict(zip(outage_data['istio.canonical_service'], outage_data['down_probability']))
    return dict(zip(outage_data['istio.canonical_service'], outage_data['down_probability']))

def getNodeID(node_names, app_name):
    '''
    getNodeID gets the index of an app in the node_names list. If the app
    wasn't seen before it appends the new app into the list.
    '''
    try:
        return node_names.index(app_name) + 1
    except ValueError:
        newid = len(node_names) + 1
        node_names.append(app_name)
        return newid

def genGraph(raw_metrics, outage_data):
    '''
    genGraph generates a json-like dictionary in the specification requested by
    the Node Graph API grafana data source containing a graph of apps based on
    the raw_metrics dictionary.
    '''

    node_names = {}
    edges = []

    for metric in raw_metrics:
        value = int(float(metric['value'][1]))

        # ignore all source destination pairs that haven't seen new requests
        if value <= 0:
            continue

        source_name = metric['metric']['source_workload']
        dest_name = metric['metric']['destination_workload']

        # Add nodes if not already present
        if source_name not in node_names:
            node_names[source_name] = {'id': len(node_names) + 1, 'down_probability': 0.0}
        if dest_name not in node_names:
            node_names[dest_name] = {'id': len(node_names) + 1, 'down_probability': 0.0}

        # Update edges
        edges.append({'id': len(edges) + 1, 
                      'source': node_names[source_name]['id'], 
                      'target': node_names[dest_name]['id'], 
                      'mainStat': value})

    # Add outage percentages and colors
    nodes = []
    for name, details in node_names.items():
        down_probability = outage_data.get(name, 0.0)
        color = "green"  # Default color

        # Determine color based on down probability
        if down_probability <= 0.500:
            color = "green"
        elif 0.6 <= down_probability <= 0.750:
            color = "yellow"
        elif down_probability > 0.750:
            color = "red"

        nodes.append({'id': details['id'], 
                      'title': f"{name} ({down_probability * 100:.2f}%)",  # Show percentage in title
                      'down_probability': down_probability,
                      'color': color})

    return {"nodes": nodes, "edges": edges}

@app.route('/api/graph/fields')
def graphFields():
    '''
    graphFields handles the graph description API endpoint for Node Graph API.
    '''
    return flask.send_file('fields.json')

@app.route('/api/graph/data')
def graphData():
    '''
    graphData handles the graph data endpoint for the Node Graph API. It makes
    a query in a Prometheus database that has Istio metrics and generates the
    graph of apps that connect to each other in the period of time specified.
    '''
    raw_query = flask.request.args.get('query')
    if raw_query is None:
        return flask.Response('Bad request', 400)
    raw_query = raw_query.split(' ')
    if len(raw_query) < 2:
        return flask.Response('Bad request', 400)

    namespace = raw_query[0]
    interval = raw_query[1]
    offset = None if len(raw_query) < 3 else raw_query[2]

    query = f'''
    sum by (source_workload, destination_workload) (increase(
        istio_requests_total{{source_workload_namespace="{namespace}", destination_workload!="unknown"}}[{interval}]
        {f"offset {offset}" if offset is not None else ""}
    ))
    '''

    try:
        data = requests.get(f'{os.environ["PROMETHEUS_URL"]}/api/v1/query',
                            {'query': query}).json()

        if data['status'] != 'success':
            return flask.Response('Prometheus failed', 500)
        if data['data']['resultType'] != 'vector':
            return flask.Response('Expected vector as query response', 500)

        # Load outage data before generating the graph
        outage_data = load_outage_data('traces/data.csv')  # Update the path to your CSV file
        return flask.jsonify(genGraph(data['data']['result'], outage_data))

    except Exception as e:
        return flask.Response(f'{type(e).__name__}: {e}', 500)

@app.route('/api/health')
def checkHealth():
    '''
    checkHealth handles the health-checking endpoint for the Node Graph API.
    '''
    return 'Healthy'

# Start the server with Waitress
waitress.serve(app, host='0.0.0.0', port=8080)

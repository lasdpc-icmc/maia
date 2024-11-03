import flask
import requests
import waitress
import os
import pandas as pd

app = flask.Flask('nodegraph-generator')

# Load outage data from CSV
outage_data = pd.read_csv('traces/data.csv')  # Update the path to your CSV file
outage_map = dict(zip(outage_data['istio.canonical_service'], outage_data['down_probability']))

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

def genGraph(raw_metrics):
    '''
    genGraph generates a json-like dictionary in the specification requested by
    the Node Graph API grafana data source containing a graph of apps based on
    the raw_metrics dictionary.
    '''
    node_names = []
    edges = []

    for metric in raw_metrics:
        value = int(float(metric['value'][1]))

        # Ignore all source destination pairs that haven't seen new requests
        if value <= 0:
            continue

        source_id = getNodeID(metric['metric']['source_workload'])
        dest_id = getNodeID(metric['metric']['destination_workload'])

        edges.append({
            'id': len(edges) + 1,
            'source': source_id,
            'target': dest_id,
            'mainStat': value
        })

    nodes = []
    for i, name in enumerate(node_names):
        # Retrieve the down_probability, default to 0 if not found
        down_probability = outage_map.get(name, 0.0)

        # Determine the color based on down_probability
        if down_probability <= 0.5:
            color = "green"
        elif 0.6 <= down_probability <= 0.75:
            color = "yellow"
        else:  # down_probability > 0.75
            color = "red"

        nodes.append({
            'id': i + 1,
            'title': name,
            'down_probability': down_probability,
            'color': color  # Add color attribute
        })

    return {"nodes": nodes, "edges": edges}

@app.route('/api/graph/fields')
def graphFields():
    '''
    graphFields handles the graph description api endpoint for Node Graph API.
    '''
    return flask.send_file('fields.json')

@app.route('/api/graph/data')
def graphData():
    '''
    graphData handles the graph data endpoint for the Node Graph API. It makes
    a query in a prometheus database that has istio metrics and generates the
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

        return flask.jsonify(genGraph(data['data']['result']))

    except Exception as e:
        return flask.Response(f'{type(e).__name__}: {e}', 500)

@app.route('/api/health')
def checkHealth():
    '''
    checkHealth handles the healthchecking endpoint for the Node Graph API.
    '''
    return 'Healthy'

# Start the server with Waitress
waitress.serve(app, host='0.0.0.0', port=8080)

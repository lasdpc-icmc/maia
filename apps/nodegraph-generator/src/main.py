import flask
import requests
import waitress
import os
import pandas as pd
import redis

app = flask.Flask('nodegraph-generator')

# Configure Redis connection
redis_host = os.environ.get('REDIS_URL')
redis_port = os.environ.get('REDIS_PORT', 6379)
redis_client = redis.StrictRedis(host=redis_host, port=redis_port, decode_responses=True)

def load_outage_data():
    '''
    Load outage data from Redis into a dictionary.
    '''
    outage_map = {}
    keys = redis_client.keys('down_probability:*')
    for key in keys:
        service_name = key.split(':')[-1]  # Extract the service name from the key
        down_probability = float(redis_client.get(key))
        outage_map[service_name] = down_probability
    return outage_map

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

        # Ignore all source-destination pairs that haven't seen new requests
        if value <= 0:
            continue

        source_name = metric['metric']['source_workload']
        dest_name = metric['metric']['destination_workload']

        # Add nodes if not already present
        if source_name not in node_names:
            node_names[source_name] = {'id': len(node_names) + 1}
        if dest_name not in node_names:
            node_names[dest_name] = {'id': len(node_names) + 1}

        edges.append({
            'id': len(edges) + 1, 
            'source': node_names[source_name]['id'], 
            'target': node_names[dest_name]['id'], 
            'mainStat': value
        })

    # Add outage percentages, colors, and display text
    nodes = []
    for name, details in node_names.items():
        down_probability = outage_data.get(name, 0.0)
        color = "green"  # Default color

        if down_probability < 0.45:
            color = "green"
        elif 0.45 <= down_probability <= 0.6:
            color = "yellow"
        elif down_probability > 0.6:
            color = "red"

        # Include mainStat for node display text
        nodes.append({
            'id': details['id'],
            'title': name, 
            'mainStat': f"{down_probability * 100:.2f}%",
            'down_probability': down_probability,
            'color': color
        })

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
    queries in a Prometheus database that has Istio metrics and generates the
    graph of apps that connect to each other in the specified period of time.
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

    http_query = f'''
    sum by (source_workload, destination_workload) (increase(
        istio_requests_total{{source_workload_namespace="{namespace}", destination_workload!="unknown"}}[{interval}]
        {f"offset {offset}" if offset is not None else ""}
    ))
    '''
    tcp_query = f'''
    sum by (source_workload, destination_workload) (increase(
        istio_tcp_connections_opened_total{{source_workload_namespace="{namespace}", destination_workload!="unknown"}}[{interval}]
        {f"offset {offset}" if offset is not None else ""}
    ))
    '''

    try:
        http_response = requests.get(f'{os.environ["PROMETHEUS_URL"]}/api/v1/query', {'query': http_query}).json()
        if http_response['status'] != 'success' or http_response['data']['resultType'] != 'vector':
            return flask.Response('Prometheus HTTP query failed', 500)

        tcp_response = requests.get(f'{os.environ["PROMETHEUS_URL"]}/api/v1/query', {'query': tcp_query}).json()
        if tcp_response['status'] != 'success' or tcp_response['data']['resultType'] != 'vector':
            return flask.Response('Prometheus TCP query failed', 500)

        outage_data = load_outage_data()

        # Combine HTTP and TCP metrics
        all_metrics = http_response['data']['result'] + tcp_response['data']['result']

        return flask.jsonify(genGraph(all_metrics, outage_data))

    except Exception as e:
        return flask.Response(f'{type(e).__name__}: {e}', 500)


@app.route('/api/health')
def checkHealth():
    '''
    checkHealth handles the health-checking endpoint for the Node Graph API.
    '''
    return 'Healthy'

waitress.serve(app, host='0.0.0.0', port=8080)
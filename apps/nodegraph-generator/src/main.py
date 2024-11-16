import flask
import requests
import waitress
import os
import redis

app = flask.Flask('nodegraph-generator')

# Configure Redis connection
redis_host = os.environ.get('REDIS_URL', 'localhost')
redis_port = int(os.environ.get('REDIS_PORT', 6379))
redis_client = redis.StrictRedis(host=redis_host, port=redis_port, decode_responses=True)

def load_outage_data():
    '''
    Load outage data from Redis into a dictionary.
    '''
    outage_map = {}
    keys = redis_client.keys('down_probability:*')
    for key in keys:
        service_name = key.split(':')[-1]  # Extract the service name from the key
        try:
            down_probability = float(redis_client.get(key))
            outage_map[service_name] = down_probability
        except (ValueError, TypeError):
            pass  # Ignore invalid or missing values
    return outage_map

def getNodeID(node_names, app_name):
    '''
    Get the ID of a node, adding it to the list if not already present.
    '''
    if app_name not in node_names:
        node_names[app_name] = len(node_names) + 1
    return node_names[app_name]

def genGraph(raw_metrics, outage_data):
    '''
    Generate a JSON-like dictionary for the Node Graph API containing a graph
    of apps based on the raw_metrics dictionary.
    '''
    node_names = {}
    edges = []

    for metric in raw_metrics:
        try:
            value = int(float(metric['value'][1]))

            if value <= 0:
                continue

            source_name = metric['metric'].get('source_workload', 'unknown')
            dest_name = metric['metric'].get('destination_workload', 'unknown')

            source_id = getNodeID(node_names, source_name)
            dest_id = getNodeID(node_names, dest_name)

            edges.append({
                'id': len(edges) + 1,
                'source': source_id,
                'target': dest_id,
                'mainStat': value
            })
        except (KeyError, ValueError):
            continue  # Skip metrics with missing or invalid data

    nodes = []
    for name, node_id in node_names.items():
        down_probability = outage_data.get(name, 0.0)
        if down_probability < 0.45:
            color = "green"
        elif 0.45 <= down_probability <= 0.6:
            color = "yellow"
        else:
            color = "red"

        nodes.append({
            'id': node_id,
            'title': name,
            'mainStat': f"{down_probability * 100:.2f}%",
            'down_probability': down_probability,
            'color': color
        })

    return {"nodes": nodes, "edges": edges}

@app.route('/api/graph/fields')
def graphFields():
    '''
    Handle the graph description API endpoint for Node Graph API.
    '''
    try:
        return flask.send_file('fields.json')
    except Exception as e:
        return flask.Response(f'{type(e).__name__}: {e}', 500)

@app.route('/api/graph/data')
def graphData():
    '''
    Handle the graph data endpoint for Node Graph API.
    '''
    raw_query = flask.request.args.get('query')
    if not raw_query:
        return flask.Response('Bad request: query parameter missing', 400)

    raw_query_parts = raw_query.split(' ')
    if len(raw_query_parts) < 2:
        return flask.Response('Bad request: query format invalid', 400)

    namespace = raw_query_parts[0]
    interval = raw_query_parts[1]
    offset = raw_query_parts[2] if len(raw_query_parts) > 2 else None

    query = f'''
    sum by (source_workload, destination_workload) (
        increase(
            istio_requests_total{{source_workload_namespace="{namespace}", destination_workload!="unknown"}}[{interval}]
            {f"offset {offset}" if offset else ""}
        )
    ) + 
    sum by (source_workload, destination_workload) (
        increase(
            istio_tcp_connections_opened_total{{source_workload_namespace="{namespace}", destination_workload!="unknown"}}[{interval}]
            {f"offset {offset}" if offset else ""}
        )
    )
    '''

    try:
        prometheus_url = os.environ.get("PROMETHEUS_URL", "http://localhost:9090")
        response = requests.get(f'{prometheus_url}/api/v1/query', params={'query': query})
        data = response.json()

        if data.get('status') != 'success':
            return flask.Response('Prometheus query failed', 500)

        result_type = data['data'].get('resultType')
        if result_type != 'vector':
            return flask.Response('Expected vector as query response', 500)

        outage_data = load_outage_data()
        graph = genGraph(data['data']['result'], outage_data)
        return flask.jsonify(graph)

    except Exception as e:
        return flask.Response(f'{type(e).__name__}: {e}', 500)

@app.route('/api/health')
def checkHealth():
    '''
    Handle the health-checking endpoint for the Node Graph API.
    '''
    return 'Healthy'

if __name__ == '__main__':
    waitress.serve(app, host='0.0.0.0', port=8080)

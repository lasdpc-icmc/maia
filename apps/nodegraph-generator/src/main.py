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

def genGraph(raw_http_metrics, raw_tcp_metrics, outage_data):
    '''
    Generate a JSON-like dictionary for the Node Graph API containing a graph
    of apps based on the raw_http_metrics and raw_tcp_metrics dictionaries.
    '''
    node_names = {}
    edges = []

    # Process HTTP metrics
    for metric in raw_http_metrics:
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
                'mainStat': f"HTTP: {value}"
            })
        except (KeyError, ValueError):
            continue  # Skip metrics with missing or invalid data

    # Process TCP metrics
    for metric in raw_tcp_metrics:
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
                'mainStat': f"TCP: {value}"
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

@app.route('/api/graph/data')
def graphData():
    '''
    Handle the graph data endpoint for Node Graph API, including HTTP and TCP metrics.
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

    try:
        prometheus_url = os.environ.get("PROMETHEUS_URL", "kube-prometheus-kube-prome-prometheus.monitoring.svc.cluster.local:9090")

        # HTTP Metrics Query
        http_query = f'''
        sum by (source_workload, destination_workload) (increase(
            istio_requests_total{{source_workload_namespace="{namespace}"}}[{interval}]
            {f"offset {offset}" if offset else ""}
        ))
        '''

        # TCP Metrics Query
        tcp_query = f'''
        sum by (source_workload, destination_workload) (increase(
            istio_tcp_connections_opened_total{{source_workload_namespace="{namespace}"}}[{interval}]
            {f"offset {offset}" if offset else ""}
        ))
        '''

        # Query Prometheus
        http_response = requests.get(f'{prometheus_url}/api/v1/query', params={'query': http_query})
        tcp_response = requests.get(f'{prometheus_url}/api/v1/query', params={'query': tcp_query})

        http_data = http_response.json().get('data', {}).get('result', [])
        tcp_data = tcp_response.json().get('data', {}).get('result', [])

        if not http_response.ok or not tcp_response.ok or not http_data and not tcp_data:
            return flask.Response('No metrics found or Prometheus query failed', 500)

        # Merge HTTP and TCP metrics
        combined_metrics = http_data + tcp_data

        # Load outage data from Redis
        outage_data = load_outage_data()

        # Generate the graph
        graph = genGraph(combined_metrics, outage_data)
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

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

def genGraph(raw_metrics, outage_data):
    '''
    genGraph generates a json-like dictionary in the specification requested by
    the Node Graph API Grafana data source containing a graph of apps based on
    the raw_metrics dictionary.
    '''

    node_names = {}
    edges = []
    arc_sections = []

    # Track the number of apps in each status category for arc sections
    healthy_count = 0
    warning_count = 0
    critical_count = 0

    for metric in raw_metrics:
        try:
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
                'arc__outage': value  # Replaced 'mainStat' with 'arc__outage'
            })
        except Exception as e:
            # Log or handle the error gracefully if the metric is not formatted as expected
            print(f"Error processing metric: {e}")
            continue

    # Add outage percentages, colors, and display text
    nodes = []
    for name, details in node_names.items():
        down_probability = outage_data.get(name, 0.0)
        status = "Healthy"
        arc__color = "green"  # Default color

        if down_probability < 0.45:
            arc__color = "green"
            status = "Healthy"
            healthy_count += 1
        elif 0.45 <= down_probability <= 0.6:
            arc__color = "yellow"
            status = "Warning"
            warning_count += 1
        elif down_probability > 0.6:
            arc__color = "red"
            status = "Critical"
            critical_count += 1

        # Include arc__outage for node display text
        nodes.append({
            'id': details['id'],
            'title': name, 
            'arc__outage': f"{down_probability * 100:.2f}%",  # Replaced 'mainStat' with 'arc__outage'
            'down_probability': down_probability,
            'arc__color': arc__color,  # Replaced 'color' with 'arc__color'
            'status': status  # Status to be used in the legend
        })

    # Add arc sections as metrics with the 'arc_' prefix for Grafana to recognize them
    arc_sections = [
        {
            'name': 'arc_Healthy',
            'arc__color': 'green',
            'arc__outage': healthy_count
        },
        {
            'name': 'arc_Warning',
            'arc__color': 'yellow',
            'arc__outage': warning_count
        },
        {
            'name': 'arc_Critical',
            'arc__color': 'red',
            'arc__outage': critical_count
        }
    ]

    return {
        "nodes": nodes,
        "edges": edges,
        "arcSections": arc_sections  # Provide the arc sections for the legend
    }


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

        # Load outage data from Redis before generating the graph
        outage_data = load_outage_data()  # No need to pass a file path now
        return flask.jsonify(genGraph(data['data']['result'], outage_data))

    except Exception as e:
        return flask.Response(f'{type(e).__name__}: {e}', 500)

@app.route('/api/health')
def checkHealth():
    '''
    checkHealth handles the health-checking endpoint for the Node Graph API.
    '''
    return 'Healthy'

waitress.serve(app, host='0.0.0.0', port=8080)

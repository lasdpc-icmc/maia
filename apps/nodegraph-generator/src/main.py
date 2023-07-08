import flask
import requests
import waitress
import os

app = flask.Flask('nodegraph-generator')


def getNodeID(node_names, app_name):
    '''
    getNodeID gets the index of an app in the node_names list. If the app
    wasn't seen before it appends the new app into the list.
    '''

    try:
        return node_names.index(app_name)+1
    except ValueError:
        newid = len(node_names)+1
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

        # ignore all source destination pairs that haven't seen new requests
        if value <= 0:
            continue

        source_id = getNodeID(
            node_names, metric['metric']['source_workload'])

        dest_id = getNodeID(
            node_names, metric['metric']['destination_workload'])

        edges.append({'id': len(edges)+1, 'source': source_id,
                     'target': dest_id, 'mainStat': value})

    nodes = []
    for i, name in enumerate(node_names):
        nodes.append({'id': i+1, 'title': name})

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

    The prometheus database to query must have it's URL stored in the
    PROMETHEUS_URL environment variable.

    The query format has the following arguments: namespace, which is the
    namespace of apps to look into (connections to services in other workspaces
    are ignored); interval, which is the time span to look for connections; and
    offset, which is the time offset for the end of the interval.
    '''

    namespace = flask.request.args.get('namespace')
    interval = flask.request.args.get('interval')
    offset = flask.request.args.get('offset')
    if namespace is None or interval is None:
        return flask.Response('Bad request', 400)

    query = f'\
    sum by (source_workload, destination_workload) (increase( \
        istio_requests_total{{source_workload_namespace="{namespace}", \
                             destination_workload!="unknown"}}[{interval}] \
        {f"offset {offset}" if offset is not None else ""} \
    ))'

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


waitress.serve(app, host='0.0.0.0', port=8080)

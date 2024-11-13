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
        subtitle = "Health - 65%"  # Default subtitle

        if down_probability < 0.45:
            color = "green"
            if down_probability < 0.1:
                subtitle = "Potential Error - 10%"
            elif down_probability < 0.4:
                subtitle = "Warning - 40%"
            else:
                subtitle = "Health - 65%"
        elif 0.45 <= down_probability <= 0.6:
            color = "yellow"
            subtitle = "Warning - 40%"
        elif down_probability > 0.6:
            color = "red"
            subtitle = "Potential Error - 10%"

        # Include mainStat for node display text
        nodes.append({
            'id': details['id'],
            'title': name, 
            'mainStat': subtitle,
            'down_probability': down_probability,
            'color': color
        })

    return {"nodes": nodes, "edges": edges}

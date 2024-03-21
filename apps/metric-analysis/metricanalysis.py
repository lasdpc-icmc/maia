import pandas as pd


def correlate(timestamps, metrics, test_seconds):
    failure_df = timestamps_to_df(timestamps, test_seconds)

    correlations = {}
    for name in metrics:
        metric = pd.DataFrame(metrics[name])

        corr = metric.corrwith(failure_df.value)
        correlations[name] = dict(zip(metric.keys(), corr))

    return correlations


def timestamps_to_df(timestamps, test_seconds):
    timestamps_unfold = []
    ts_now_i = 0

    step = 0

    while ts_now_i < len(timestamps):
        start, duration = timestamps[ts_now_i]
        if step < start:
            timestamps_unfold.append(0)
            step += 30
        elif step <= start + duration:
            timestamps_unfold.append(1)
            step += 30
        else:
            ts_now_i += 1
            continue

    for _ in range(step, test_seconds, 30):
        timestamps_unfold.append(0)

    return pd.DataFrame({"value": timestamps_unfold})

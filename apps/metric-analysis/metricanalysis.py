import pandas as pd
import statsmodels.api as sm
from sklearn.preprocessing import StandardScaler


def best_metrics(timestamps, metrics, test_seconds):
    failure_df = timestamps_to_df(timestamps, test_seconds)

    individual_metrics = pd.DataFrame()

    for name in metrics:
        metric = pd.DataFrame(metrics[name])
        metric = metric.rename(columns=lambda subname: f'{name}-{subname}')
        drop_constants(metric)
        individual_metrics = pd.concat([individual_metrics, metric], axis=1)

    metrics_scaled = pd.DataFrame(StandardScaler().fit_transform(
        individual_metrics), columns=individual_metrics.columns)

    regression = sm.Logit(failure_df["value"],
                          sm.add_constant(metrics_scaled)).fit(method='bfgs')

    return pd.concat([regression.params.rename('parameter'), regression.conf_int()], axis=1)


def drop_constants(df):
    for column in df:
        if df[column].std() <= 0.05:
            del df[column]


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

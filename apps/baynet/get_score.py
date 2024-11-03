import pandas as pd
import numpy as np

# Define thresholds and penalties
# TO DO another function to get it dinamycally from Prometheus and ISTIO


DURATION_THRESHOLD = 1e9  # 1 second in nanoseconds
DURATION_PENALTY = 0.4    # penalty weight for duration

RATE_THRESHOLD = 0.7      # 70% 2xx rate
RATE_PENALTY = 0.3        # penalty weight for 2xx rate

P99_THRESHOLD = 2e8       # 200ms in nanoseconds
P99_PENALTY = 0.2         # penalty weight for p99

STATUS_CODE_PENALTY = 0.5 # penalty for 500s status codes
DEPLOY_PENALTY = 0.2      # penalty for recent deploys with TTL < 60

df = pd.read_csv('traces/preprocessed_traces.csv')

def calculate_score(row):
    score = 1.0

    # Apply penalty based on duration
    if row['durationNanos'] > DURATION_THRESHOLD:
        penalty = DURATION_PENALTY * (row['durationNanos'] / DURATION_THRESHOLD)
        score -= min(penalty, DURATION_PENALTY)

    # Apply penalty based on 2xx rate
    if row['2xx_rate'] < RATE_THRESHOLD:
        penalty = RATE_PENALTY * ((RATE_THRESHOLD - row['2xx_rate']) / RATE_THRESHOLD)
        score -= min(penalty, RATE_PENALTY)

    # Apply penalty based on p99
    if row['p99'] > P99_THRESHOLD:
        penalty = P99_PENALTY * (row['p99'] / P99_THRESHOLD)
        score -= min(penalty, P99_PENALTY)

    # Apply penalty for HTTP 500 family status codes
    if 500 <= row['http.status_code'] < 600:
        score -= STATUS_CODE_PENALTY

    # Check for recent_deploy flag and TTL condition
    if row.get('recent_deploy', False) and row.get('TTL', float('inf')) < 60:
        score -= DEPLOY_PENALTY

    score = max(0, min(score, 1))
    return score

df['score'] = df.apply(calculate_score, axis=1)

result_df = df[['istio.canonical_service', 'score']]

result_df.to_csv('traces/service_scores.csv', index=False)
print("Scoring complete. Results saved to 'service_scores.csv'")

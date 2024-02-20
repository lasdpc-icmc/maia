import numpy as np
import datetime

def generateTimestamps(options):
    timestamps = []
    for _ in range(options["failure_number"]):
        failure_time = np.random.uniform(
                0, options["test_seconds"] - options["avg_failure_seconds"])

        failure_duration = np.random.normal(
                options["avg_failure_seconds"], 
                options["std_failure_seconds"]
        )

        timestamps.append((failure_time, failure_duration))

    # since the array is expected to be small (<100 elements), this is 
    # acceptable instead of using a sorted insert in the loop above
    timestamps.sort()

    # delete all overlaps, changing them to a single bigger failure timestamp
    i = 0
    popped = 0
    while i < options["failure_number"] - 1 - popped:
        if timestamps[i][0] + timestamps[i][1] < timestamps[i+1][0]:
            i += 1
            continue
        
        timestamps[i] = (
                timestamps[i][0], 
                timestamps[i+1][0] - timestamps[i][0] + timestamps[i+1][1])
        timestamps.pop(i+1)
        popped += 1

    return timestamps

def executeTest(timestamps, failure_yaml, dry_run, options):
    if dry_run or True:
        now = datetime.datetime.now(datetime.UTC).timestamp()
        return now - options["test_seconds"] - 30

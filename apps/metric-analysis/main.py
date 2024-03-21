#!/usr/bin/env python3
import sys
import logging
import json
import jsonschema
import os
import asyncio

import failuregen
import metricgather
import metricanalysis

# schema for the options file
options_schema = {
    "type": "object",
    "properties": {
        "avg_failure_seconds": {"type": "number"},
        "std_failure_seconds": {"type": "number"},
        "failure_number": {"type": "number"},
        "test_seconds": {"type": "number"},
        "test_namespace": {"type": "string"}
    },
    "required": [
        "avg_failure_seconds", "std_failure_seconds", "failure_number",
        "test_seconds", "test_namespace"
    ],
}

if __name__ == "__main__":
    if len(sys.argv) <= 1 or not os.path.isdir(sys.argv[1]):
        print(f"execution directory required: {sys.argv[0]} <directory name>",
              file=sys.stderr)
        exit(-1)

    execution_dir = sys.argv[1]

    # delete old log file if it exists
    try:
        os.remove(os.path.join(execution_dir, "out.log"))
    except Exception:
        pass

    logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                        filename=os.path.join(execution_dir, 'out.log'),
                        level=logging.INFO)
    logger = logging.getLogger("main")

    # dry run means a "mock" run, to simulate what would happen in an actual
    # test
    dry_run = False
    if len(sys.argv) > 2 and sys.argv[2] == "--dry-run":
        dry_run = True
        logger.info("dry running")

    logger.info("reading options files")

    f = open(os.path.join(execution_dir, "options.json"))
    options = json.load(f)
    jsonschema.validate(options, options_schema)
    f.close()

    logger.info("generating failure timestamps")
    timestamps = failuregen.generateTimestamps(options)

    logger.info(f"(timestamps, durations): {timestamps}")

    logger.info("starting test execution")
    test_start = failuregen.executeTest(
        timestamps, os.path.join(execution_dir, "failure.yaml"),
        dry_run, options)

    logger.info("done with test execution")

    logger.info("obtaining prometheus metrics")
    metrics = asyncio.run(metricgather.getMetrics(
        os.path.join(execution_dir, "metrics.csv"), test_start,
        dry_run, options))

    f = open(os.path.join(execution_dir, "metrics_data.json"), "w")
    json.dump(metrics, f)
    f.close()

    logger.info("obtaining correlation")
    correlation = metricanalysis.correlate(timestamps, metrics,
                                           options["test_seconds"])

    f = open(os.path.join(execution_dir, "correlation.json"), "w")
    json.dump(correlation, f)
    f.close()

    logger.info("done!")

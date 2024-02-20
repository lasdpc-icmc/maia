# Metric Analysis Test Execution Script
This script to execute a complete failure test in k8s and correlate the anomaly with metrics.

## Running the Script and Arguments
run `./main.py <directory>` after installing the packages in `requirements.txt`, ideally in a virtual environment. The directory must contain the following files:
* metrics.csv, containing the metrics to be scraped by prometheus (the format of the csv will be provided in the future)
* options.json, containing all options, including test execution time
* failure.yaml, containing the k8s chaos mesh resource to create the error

## Execution Steps
### Input Reading
* see which failure the user chose, the amount of time the test will run, the amount of failures that will happen during the test, and the mean failure time
* select random timestamps with the correct size to execute failures
### Test Execution:
* start the loadtest with locust
* create and destroy the chaos mesh resources (aka generate the errors according to the timestamps)
* stop the loadtest
### Metric Analysis:
* obtain the metrics during the test execution via prometheus api
* correlate the failure times with metrics using cross-correlation
### Output:
* ouput the most correlated metrics with the failure to a file

#!/bin/bash
set -xe
source ./.circleci/common.sh;
env_vars

# Install Dependencies
export GATLING_HOME="/home/circleci/project/gatling-charts-highcharts-bundle-2.3.1"
install_awscli_kubectl
aws_credentials

# Install Gatling

wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/2.3.1/gatling-charts-highcharts-bundle-2.3.1-bundle.zip
unzip gatling-charts-highcharts-bundle-2.3.1-bundle.zip
rm $GATLING_HOME/user-files/simulations/computerdatabase/*.scala
cp /home/circleci/project/apps/$APP/loadtest/* $GATLING_HOME/user-files/simulations/computerdatabase/
$GATLING_HOME/bin/gatling.sh -s computerdatabase.BasicSimulation

cd $GATLING_HOME/results/
tar -cvf $APP-$(date +%Y-%m-%d).tar.gz *

# Push results

aws_run s3 sync $APP-$(date +%Y-%m-%d).tar.gz s3://gatling-metrics-application-results/$APP-$(date +%Y-%m-%d).tar.gz                                                                                                   82.155.232.198 IP ▓▒░
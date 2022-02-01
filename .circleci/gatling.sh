#!/bin/bash
set -xe
source ./.circleci/common.sh;
env_vars

# Configure VM

export GATLING_HOME="/home/circleci/project/gatling-charts-highcharts-bundle-2.3.1"

# Install Gatling

wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/2.3.1/gatling-charts-highcharts-bundle-2.3.1-bundle.zip
unzip gatling-charts-highcharts-bundle-2.3.1-bundle.zip
rm $GATLING_HOME/user-files/simulations/computerdatabase/*.scala
cp /home/circleci/project/$APP/loadtest/* $GATLING_HOME/user-files/simulations/computerdatabase/
$GATLING_HOME/bin/gatling.sh -s computerdatabase.BasicSimulation

cd $GATLING_HOME/results/
tar -cvf $APP.tar.gz *
/

# Push results 


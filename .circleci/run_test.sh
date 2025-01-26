#!/bin/bash
set -xe
source ./.circleci/common.sh;

sudo apt-get update
sudo apt-get install gitleaks -y

gitleaks detect --source=$(pwd) --config=.gitleaks.toml --report-format=json --report-path=gitleaks_report.json --verbose
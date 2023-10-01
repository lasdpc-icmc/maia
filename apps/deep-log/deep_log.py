import torch
import aws_tools
import os
import json
import boto3
import subprocess
import numpy as np
import deep_log_train
import deep_log_predict
import drain_parser

from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from sklearn.metrics import classification_report
from loki import get_loki_logs

MODEL_STABLE_VERSION = os.environ['MODEL_STABLE_VERSION']
FIRST_TRANING = os.environ['FIRST_TRANING']

LOKI_URL = os.environ['LOKI_URL']
APP_NAME = os.environ['APP_NAME']
TIME_RANGE = int(os.environ['TIME_RANGE'])
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
AWS_REGION = os.environ['AWS_REGION']
S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']

file_name = get_loki_logs(LOKI_URL, APP_NAME, TIME_RANGE,
                          AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET_NAME)


def main():

    if FIRST_TRANING.lower() == 'true':
        drain_parser.proccess_logs_files(file_name)
        deep_log_train.train_model(file_name)
        deep_log_predict.model_predict(file_name)
        print(f"Training completed for {file_name}")
    else:
        deep_log_train.train_model(file_name, first_train=False)
        deep_log_predict.model_predict(file_name)
        print(f"Prediction completed for {file_name}")


if __name__ == "__main__":
    main()

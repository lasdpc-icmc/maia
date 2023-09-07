import torch
import aws_tools
import os
import json
import numpy as np
import boto3

from drain_parser import file_name
from drain_parser import persistence
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from sklearn.metrics import classification_report
from deep_log_train import train_model
from deep_log_predict import model_predict

def main(train = True):
    version = 12
    if train == True:
        train_model(file_name)
        model_predict(file_name)
        print ("diego1")

    else:
        train_model(file_name, first_train=False)
        model_predict(file_name)
        print ("diego2")

main(train = False)

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
bucket_name = S3_BUCKET_NAME
prefix = 'clean/'
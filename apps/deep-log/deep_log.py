import torch
import aws_tools
import os
from drain_parser import file_name
import json

# Import DeepLog and Preprocessor
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor

# Imports for showing metrics
import numpy as np
from sklearn.metrics import classification_report
from deep_log_train import train_model
from deep_log_predict import model_predict


import boto3


def main():
    train = 'test'
    if train == True:
        train_model(file_name)
        model_predict(file_name)

    elif train == 'test':
        exit()
    
    else:
        model_predict(file_name)


S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
bucket_name = S3_BUCKET_NAME
prefix = 'clean/'



def list_s3_files(prefix):
    s3 = boto3.client('s3')
    bucket_name = S3_BUCKET_NAME
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    files = []
    if 'Contents' in response:
        for file in response['Contents']:
            files.append(file['Key'])
    
    files = [j[6:] for j in files]
    return files




prefix = 'clean/'
s3_path = "predict"
file_to_run = list_s3_files(prefix)

#train_model(file_name = 'whatever', first_train=True, version = 10)
for file_name in file_to_run:
    model_predict(file_name)
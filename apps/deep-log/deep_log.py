import torch
import aws_tools
import os
from drain_parser import file_name


# Import DeepLog and Preprocessor
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor

# Imports for showing metrics
import numpy as np
from sklearn.metrics import classification_report
from deep_log_train import train_model
from deep_log_predict import model_predict



def main():
    train = False
    if train == True:
        train_model(file_name)
        model_predict(file_name)

    else:
        model_predict(file_name)


main()
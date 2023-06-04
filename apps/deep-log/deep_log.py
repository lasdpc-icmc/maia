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

train = True

def main():
    if train == True:
        import deep_log_train, deep_log_predict

    else:
        import deep_log_predict


main()
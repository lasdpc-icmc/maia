from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from deep_log_metrics import save_model, load_model
import torch
import aws_tools
import os
import json

MODEL_STABLE_VERSION = os.environ['MODEL_STABLE_VERSION']
first_train = os.environ['FIRST_TRANING']

def train_model(file_name):

    file_name = file_name[:-4]

    ##############################################################################
    #                                 Load data                                  #
    ##############################################################################

    # Create preprocessor for loading data

    preprocessor = Preprocessor(
        length=20,           # Extract sequences of 20 items
        # Do not include a maximum allowed time between events
        timeout=float('inf'),
    )

    file = open(f"cleansed_{file_name}.json")
    cleansed_file = json.load(file)

    with open('tempfile_train.txt', 'w') as f:
        for i in cleansed_file['cluster']:
            f.write(str(i) + ' ')

    X, y, _, _ = preprocessor.text(
        path='tempfile_train.txt',
        verbose=True,
        # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
    )

    ##############################################################################
    #                                 Train deeplog                              #
    ##############################################################################

    # Create DeepLog object
    # output_size - número de chaves diferentes, geralmente output_size = length
    deeplog = DeepLog(
        input_size=1000,  # Number of different events to expect
        hidden_size=64,  # Hidden dimension, we suggest 64
        output_size=1000,  # Number of different events to expect
    )

    if first_train == 'True':
        s3_path = "deeplog_statemodel"
        aws_tools.get_to_s3(MODEL_STABLE_VERSION, s3_path)
        load_model(deeplog, MODEL_STABLE_VERSION)


    # Train deeplog
    deeplog.fit(
        X=X,
        y=y,
        epochs=100,
        batch_size=128,
        optimizer=torch.optim.Adam,
    )

    save_model(deeplog, MODEL_STABLE_VERSION)

    if first_train == 'True':
        s3_path = "deeplog_statemodel"
        aws_tools.upload_to_s3(MODEL_STABLE_VERSION, s3_path)

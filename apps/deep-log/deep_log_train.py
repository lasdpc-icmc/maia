
import torch
import aws_tools
import os
from drain_parser import file_name



# Import DeepLog and Preprocessor
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from sklearn.metrics import classification_report


# Imports for showing metrics
import numpy as np
import json



from data_cleaning import clean_sock, read_logs, write_logs
from deep_log_metrics import get_ind_metrics, is_anomaly, save_model, load_model




def train_model(file_name, first_train = False):

    ##############################################################################
    #                                 Load data                                  #
    ##############################################################################

    # Create preprocessor for loading data
    #length - tamanho da janela a ser considerada
    preprocessor = Preprocessor(
        length  = 10,           # Extract sequences of 20 items
        timeout = float('inf'), # Do not include a maximum allowed time between events
    )

    # Dowload the file from S3
    prefix = "clean/"
    #aws_tools.get_to_s3(f'cluster_{file_name}', prefix)

    aws_tools.get_to_s3(file_name, prefix)

    file = open(file_name)
    cleansed_file = json.load(file)

    with open('tempfile_train.txt', 'w') as f:
        for i in cleansed_file['cluster']:
            f.write(str(i) + ' ')


    X, y, label, mapping = preprocessor.text(
        path    = 'tempfile_train.txt',
        verbose = True,
        # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
    )


    # Load normal data from s3
    # X, y, label, mapping = preprocessor.text(
    #     path    = f'cluster_{file_name}',
    #     verbose = True,
    #     # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
    # )



    ##############################################################################
    #                                 Train deeplog                              #
    ##############################################################################
    s3_path = "deep_log"
    if first_train == True:
        # Create DeepLog object
        #output_size - número de chaves diferentes, geralmente output_size = length
        deeplog = DeepLog(
            input_size  = 30, # Number of different events to expect
            hidden_size = 64 , # Hidden dimension, we suggest 64
            output_size = 30, # Number of different events to expect
        )

        # Train deeplog
        deeplog.fit(
            X          = X,
            y          = y,
            epochs     = 100 ,
            batch_size = 128,
            optimizer  = torch.optim.Adam,
        )


        save_model(deeplog, 'model_v2')

        
        aws_tools.upload_to_s3('deeplog_model_v2.pth', s3_path)
        os.remove('deeplog_model_v2.pth')
    
    else:
        
        aws_tools.get_to_s3('deeplog_model_v2.pth', s3_path)


        # Create DeepLog object
        #output_size - número de chaves diferentes, geralmente output_size = length
        deeplog = DeepLog(
            input_size  = 30, # Number of different events to expect
            hidden_size = 64 , # Hidden dimension, we suggest 64
            output_size = 30, # Number of different events to expect
        )


        load_model(deeplog, 'deeplog_model_v2.pth')

        # Train deeplog
        deeplog.fit(
            X          = X,
            y          = y,
            epochs     = 100 ,
            batch_size = 128,
            optimizer  = torch.optim.Adam,
        )


        save_model(deeplog, 'model_v2')

        s3_path = "deep_log"
        aws_tools.upload_to_s3('deeplog_model_v2.pth', s3_path)
        os.remove('deeplog_model_v2.pth')
    
    os.remove('tempfile_train.txt')





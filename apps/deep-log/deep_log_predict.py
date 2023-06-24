# Import DeepLog and Preprocessor
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from sklearn.metrics import classification_report

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



from deep_log_metrics import get_ind_metrics, is_anomaly, save_model, load_model


def model_predict(file_name):

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
    state_prefix = "deeplog_statemodel/"
    s3_path = "deep_log"

    #descomentar depois
    aws_tools.get_to_s3(f'deeplog_model_v10.pth', state_prefix)
    aws_tools.get_to_s3(f"cleansed_{file_name}.json", prefix)



    # Preprocessor its not implemented for .json files
    # in this chunk i convert the cluster entry in the .json to .txt 
    file = open(f"cleansed_{file_name}.json")
    cleansed_file = json.load(file)

    with open('tempfile_predict.txt', 'w') as f:
        for i in cleansed_file['cluster']:
            f.write(str(i) + ' ')



    # Load normal data from s3
    X, y, label, mapping = preprocessor.text(
        path    = 'tempfile_predict.txt',
        verbose = True,
        # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
    )

    ##############################################################################
    #                                 Load state of model                        #
    ##############################################################################


    # Create DeepLog object
    #output_size - número de chaves diferentes, geralmente output_size = length
    deeplog = DeepLog(
        input_size  = 30, # Number of different events to expect
        hidden_size = 64 , # Hidden dimension, we suggest 64
        output_size = 30, # Number of different events to expect
    )


    load_model(deeplog, 'deeplog_model_v10.pth')



    ##############################################################################
    #                                Predict logs                                #
    ##############################################################################


    # Predict normal data using deeplog
    y_pred, confidence = deeplog.predict(
        X = X,
        k = 5, # Change this value to get the top k predictions (called 'g' in DeepLog paper, see Figure 6)
    )




    #Considerando apenas o primeiro elemento do vetor de predição, o modelo acertou o próximo evento?
    individual_pred = get_ind_metrics(y, y_pred)


    ## Upload results to S3
    s3_path = "deep_log"



    # vector of anomalies
    anomalies_normal = is_anomaly(y,y_pred)




    ##############################################################################
    #                                Upload results of data batch to s3          #
    ##############################################################################

    cleansed_file['individual_pred'] = individual_pred
    cleansed_file['predictions'] = y_pred.cpu().numpy().tolist()
    cleansed_file['confidence'] = confidence.cpu().numpy().tolist()
    cleansed_file['anomalies'] = anomalies_normal.numpy().tolist()



    #file_name = file_name[8:]

    with open(f"predict_{file_name}", "w") as outfile:
        json.dump(cleansed_file, outfile)


    aws_tools.upload_to_s3(f'predict_{file_name}', s3_path)
    os.remove(f'predict_{file_name}')
    os.remove('tempfile_predict.txt')
    

    aws_tools.upload_to_s3(f'predict_{file_name}.json', s3_path)
    os.remove(f'predict_{file_name}.json')

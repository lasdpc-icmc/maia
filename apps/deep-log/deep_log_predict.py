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
    s3_path = "deep_log"
    aws_tools.get_to_s3(f'cluster_{file_name}', prefix)
    aws_tools.get_to_s3('deeplog_model_v1.pth', s3_path)



    # Load normal data from s3
    X, y, label, mapping = preprocessor.text(
        path    = f'cluster_{file_name}',
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


    load_model(deeplog, 'deeplog_model_v1.pth')



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


    res_dic = {
        'individual_pred' : individual_pred,
        'predictions': y_pred.cpu().numpy().tolist(),
        'confidence': confidence.cpu().numpy().tolist(),
        'anomalies': anomalies_normal.numpy().tolist()
    }



    file_name = file_name[:-4]
    with open(f"predict_{file_name}.json", "w") as outfile:
        json.dump(res_dic, outfile)


    aws_tools.upload_to_s3(f'predict_{file_name}.json', s3_path)
    os.remove(f'predict_{file_name}.json')

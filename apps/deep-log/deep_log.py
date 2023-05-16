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


##############################################################################
#                                 Load data                                  #
##############################################################################

# Create preprocessor for loading data
#length - tamanho da janela a ser considerada
preprocessor = Preprocessor(
    length  = 25,           # Extract sequences of 20 items
    timeout = float('inf'), # Do not include a maximum allowed time between events
)

# Dowload the file from S3
prefix = "clean/"
aws_tools.get_to_s3(f'cluster_{file_name}', prefix)

# Load normal data from HDFS dataset
X, y, label, mapping = preprocessor.text(
    path    = f'cluster_{file_name}',
    verbose = True,
    # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
)

# Split in train test data (20:80 ratio)
X_train = X[:X.shape[0]//5 ]
X_test  = X[ X.shape[0]//5:]
y_train = y[:y.shape[0]//5 ]
y_test  = y[ y.shape[0]//5:]

# Create DeepLog object
#output_size - número de chaves diferentes, geralmente output_size = length
deeplog = DeepLog(
    input_size  = 30, # Number of different events to expect
    hidden_size = 64 , # Hidden dimension, we suggest 64
    output_size = 25, # Number of different events to expect
)

# Train deeplog
deeplog.fit(
    X          = X_train,
    y          = y_train,
    epochs     = 5 ,
    batch_size = 128,
    optimizer  = torch.optim.Adam,
)

# Predict normal data using deeplog
y_pred_normal, confidence = deeplog.predict(
    X = X_test,
    k = 2, # Change this value to get the top k predictions (called 'g' in DeepLog paper, see Figure 6)
)
print("Classification report - predictions")
print(classification_report(
    y_true = y_test.cpu().numpy(),
    y_pred = y_pred_normal[:, 0].cpu().numpy(),
    digits = 4,
    zero_division = 0,
))

## Upload results to S3
s3_path = "deep_log"



shape_y = y_pred_normal.cpu().numpy().shape
vector_pred = y_pred_normal.cpu().numpy()
vector_conf = confidence.cpu().numpy()



with open(f'predict_{file_name}', 'w') as f:
    for i in range(0,shape_y[0]):
        for j in range(0,shape_y[1]):
            pred = vector_pred[i,j]
            confidence = vector_conf[i,j]
            f.write(str(pred) + ',' + str(confidence) + ';')
        f.write('\n')

aws_tools.upload_to_s3(f'predict_{file_name}', s3_path)
os.remove(f'predict_{file_name}'), os.remove(f'values_{file_name}'), os.remove(file_name)
import torch

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





# Load normal data from HDFS dataset
X, y, label, mapping = preprocessor.text(
    path    = "../book_logs.txt",
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
    epochs     = 100 ,
    batch_size = 128,
    optimizer  = torch.optim.Adam,
)


# Predict normal data using deeplog
y_pred_normal, confidence = deeplog.predict(
    X = X_test,
    k = 9, # Change this value to get the top k predictions (called 'g' in DeepLog paper, see Figure 6)
)



print("Classification report - predictions")
print(classification_report(
    y_true = y_test.cpu().numpy(),
    y_pred = y_pred_normal[:, 0].cpu().numpy(),
    digits = 4,
    zero_division = 0,
))

import json
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from deep_log_metrics import load_model
import torch
from deeplog.preprocessor import Preprocessor
import aws_tools


# Create DeepLog object
#output_size - número de chaves diferentes, geralmente output_size = length
deeplog = DeepLog(
    input_size  = 30, # Number of different events to expect
    hidden_size = 64 , # Hidden dimension, we suggest 64
    output_size = 30, # Number of different events to expect
)

prefix = "clean/"
s3_path = "deep_log"


aws_tools.get_to_s3('deeplog_model_v10.pth', s3_path)
aws_tools.get_to_s3('cleansed_sock-shop_1677876783.json', 'clean')


dict_model = torch.load('deeplog_model_v10.pth')
#print(dict_model.keys())
deeplog.load_state_dict(torch.load('deeplog_model_v10.pth'))
#load_model(deeplog, 'deeplog_model_v10.pth')

 # Preprocessor its not implemented for .json files
# in this chunk i convert the cluster entry in the .json to .txt 
file = open('cleansed_sock-shop_1677876783.json')
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



preprocessor = Preprocessor(
    length  = 10,           # Extract sequences of 20 items
    timeout = float('inf'), # Do not include a maximum allowed time between events
)

# Load normal data from s3
X, y, label, mapping = preprocessor.text(
    path    = 'tempfile_predict.txt',
    verbose = True,
    # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
    )



##############################################################################
#                                Predict logs                                #
##############################################################################


# Predict normal data using deeplog
y_pred, confidence = deeplog.predict(
    X = X,
    k = 5, # Change this value to get the top k predictions (called 'g' in DeepLog paper, see Figure 6)
)
#print(y_pred)


aws_tools.upload_to_s3('predict_seraquesobe.json', s3_path)
os.remove(f'predict_{file_name}.json')


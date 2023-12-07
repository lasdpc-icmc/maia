from deep_log_metrics import get_ind_metrics, is_anomaly

import os
import json

PREDICT_RANGE = int(os.environ['PREDICT_RANGE'])


def model_predict(preprocessor, deeplog, file_name):
    file_name = file_name[:-4]
    ##############################################################################
    #                                 Load data                                  #
    ##############################################################################

    file = open(f"cleansed_{file_name}.json")
    cleansed_file = json.load(file)

    with open('tempfile_predict.txt', 'w') as f:
        for i in cleansed_file['cluster']:
            f.write(str(i) + ' ')

    # Load normal data from s3
    X, y, _, _ = preprocessor.text(
        path='tempfile_predict.txt',
        verbose=True,
        # nrows   = 10_000, # Uncomment/change this line to only load a limited number of rows
    )

    ##############################################################################
    #                                Predict logs                                #
    ##############################################################################

    # Predict normal data using deeplog
    y_pred, confidence = deeplog.predict(
        X=X,
        # Change this value to get the top k predictions (called 'g' in DeepLog paper, see Figure 6)
        k=PREDICT_RANGE,
    )

    # Considering only the first element of the prediction vector, did the model get the next event right?
    individual_pred = get_ind_metrics(y, y_pred)

    # vector of anomalies
    anomalies_normal = is_anomaly(y, y_pred)

    ##############################################################################
    #                                Upload results of data batch to s3          #
    ##############################################################################

    cleansed_file['individual_pred'] = individual_pred
    cleansed_file['predictions'] = y_pred.cpu().numpy().tolist()
    cleansed_file['confidence'] = confidence.cpu().numpy().tolist()
    cleansed_file['anomalies'] = anomalies_normal.numpy().tolist()

    with open(f"predict_{file_name}.json", "w") as outfile:
        json.dump(cleansed_file, outfile)

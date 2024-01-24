import torch
import os
import json

def train_model(preprocessor, deeplog, file_name):

    file_name = file_name[:-4]

    ##############################################################################
    #                                 Load data                                  #
    ##############################################################################

    file = open(f"{file_name}_cleansed.json")
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

    # Train deeplog
    deeplog.fit(
        X=X,
        y=y,
        epochs=100,
        batch_size=128,
        optimizer=torch.optim.Adam,
    )

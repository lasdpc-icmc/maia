import numpy as np
from sklearn.metrics import classification_report
import torch


def save_model(deeplog, name):
    '''
    Saves deeplog state dictionary
    '''

    torch.save(deeplog.state_dict(), f'deeplog_{name}.pth')


def load_model(deeplog,path_to_pth):

    '''
    Reloads deeplog model
    '''


    deeplog.load_state_dict(torch.load(path_to_pth))

    return deeplog







## Considerando apenas o primeiro elemento do vetor de predição, o modelo acertou o próximo evento?
def get_ind_metrics(y_test, y_pred):
    '''
    Return metrics by template of logs

    y_test: Tensor, generally output of deeplog.preprocessor 
    y_pred: Tensor, predictions of deep log, output of deeplog.predict
    
    '''
    individual_pred = classification_report(
                                y_true = y_test.cpu().numpy(),
                                y_pred = y_pred[:, 0].cpu().numpy(),
                                digits = 4,
                                zero_division = 0,
                                output_dict= True
                                                )
    

    return individual_pred




# O próximo evento está em algumas dos elementos do vetor de predição?
# Se sim, o evento é classificado como normal, se não, é classificado como anomalia
def is_anomaly(y_test,y_pred):

    '''
    Returns a boolean Tensor, the elements assumes True in case of anomalies and False otherwise


    y_test: Tensor, generally output of deeplog.preprocessor 
    y_pred_normal: Tensor, predictions of deep log, output of deeplog.predict

    '''

    anomalies_normal = ~torch.any(
        y_test == y_pred.T,
        dim = 0,
    )
    
    return anomalies_normal



#Compute classification report for anomalies

# Se soubermos que um conjunto de logs contém anomalias e outro não
def overall_metrics(anomalies_normal, anomalies_abnormal):
    '''
    If we have a batch of logs that we know beforehand that are not anomalous
    and a batch of logs that we know are anomalous, we can compare the performance of deeplog in both classes


    anomalies_normal: boolean Tensor, containing classifications of deeplog for normal logs (output of is_anomaly function)
    anomalies_abnormal: boolean Tensor, containing classifications of deeplog for abnormal logs (output of is_anomaly function)

    '''



    # Compute classification report for anomalies
    y_pred = torch.cat((anomalies_normal, anomalies_abnormal))
    y_true = torch.cat((
        torch.zeros(anomalies_normal  .shape[0], dtype=bool),
        torch.ones (anomalies_abnormal.shape[0], dtype=bool),
    ))

    res = classification_report(
        y_pred       = y_pred.cpu().numpy(),
        y_true       = y_true.cpu().numpy(),
        labels       = [False, True],
        target_names = ["Normal", "Anomaly"],
        digits       = 4,
        output_dict=True
    )

    return res
from sklearn.metrics import classification_report
import torch


def save_model(deeplog, name):
    '''
    Saves deeplog state dictionary
    '''
    torch.save(deeplog.state_dict(), name)


def load_model(deeplog, path_to_pth):
    '''
    Reloads deeplog model
    '''
    deeplog.load_state_dict(torch.load(path_to_pth))
    return deeplog

# Considering only the first element of the prediction vector, did the model get the next event right?

def get_ind_metrics(y_test, y_pred):
    '''
    Return metrics by template of logs
    y_test: Tensor, generally output of deeplog.preprocessor 
    y_pred: Tensor, predictions of deep log, output of deeplog.predict

    '''
    individual_pred = classification_report(
        y_true=y_test.cpu().numpy(),
        y_pred=y_pred[:, 0].cpu().numpy(),
        digits=4,
        zero_division=0,
        output_dict=True
    )
    return individual_pred


# Is the next event in any of the elements of the prediction vector?
# If yes, the event is classified as normal, if not, it is classified as an anomaly

def is_anomaly(y_test, y_pred):
    '''
    Returns a boolean Tensor, the elements assumes True in case of anomalies and False otherwise
    y_test: Tensor, generally output of deeplog.preprocessor 
    y_pred_normal: Tensor, predictions of deep log, output of deeplog.predict

    '''

    anomalies_normal = ~torch.any(
        y_test == y_pred.T,
        dim=0,
    )

    return anomalies_normal

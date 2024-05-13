import aws_tools
import os
import deep_log_train
import deep_log_predict
import drain_parser

from deep_log_metrics import save_model, load_model
from prometheus_push_metrics import push_metrics_prometheus
from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from drain3 import TemplateMiner
from drain3.template_miner_config import TemplateMinerConfig
from datetime import timedelta

file_name = "logs/logs.txt"
FIRST_TRANING = os.environ['FIRST_TRANING']

def generate_time_batches(start_time, end_time, batch_size):
    current_time = start_time
    while current_time < end_time:
        current_time += timedelta(minutes=batch_size)
        yield current_time

def main():
    # Initialize Drain3
    config = TemplateMinerConfig()
    config.load(os.path.dirname(__file__) + "/drain3.ini")
    config.profiling_enabled = True
    template_miner = TemplateMiner( config=config)

    # Create preprocessor for loading data
    preprocessor = Preprocessor(
        length=20,           # Extract sequences of 20 items
        # Do not include a maximum allowed time between events
        timeout=float('inf'),
    )

    # Create DeepLog object
    deeplog = DeepLog(
        input_size=1000,  # Number of different events to expect
        hidden_size=64,  # Hidden dimension, we suggest 64
        output_size=1000,  # Number of different events to expect
    )

    drain_parser.proccess_logs_files(template_miner, file_name)
    deep_log_train.train_model(preprocessor, deeplog, file_name)
    deep_log_predict.model_predict(preprocessor, deeplog, file_name)
    save_model(deeplog, "deeplog_model_stable.pth")

if __name__ == "__main__":
    main()

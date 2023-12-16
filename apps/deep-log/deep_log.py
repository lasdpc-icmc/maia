import aws_tools
import os
import math

import deep_log_train
import deep_log_predict
import drain_parser
import loki
from deep_log_metrics import save_model, load_model

from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from drain3 import TemplateMiner
from drain3.template_miner_config import TemplateMinerConfig
from drain3.redis_persistence import RedisPersistence

REDIS_URL = os.environ['REDIS_URL']
REDIS_PORT = os.environ['REDIS_PORT']
REDIS_KEY = os.environ['REDIS_KEY']
TIME_RANGE = int(os.environ['TIME_RANGE'])
MODEL_STABLE_VERSION = os.environ['MODEL_STABLE_VERSION']
FIRST_TRANING = os.environ['FIRST_TRANING']
LOKI_BATCH_SIZE = int(os.environ["LOKI_BATCH_SIZE"])

# Define persistence variable that will be used regardless of Redis usage
persistence = RedisPersistence(
    redis_host=REDIS_URL,
    redis_port=REDIS_PORT,
    redis_db=0,
    redis_pass='',
    is_ssl=False,
    redis_key=REDIS_KEY
)

def main():
    # Initialize Drain3
    config = TemplateMinerConfig()
    config.load(os.path.dirname(__file__) + "/drain3.ini")
    config.profiling_enabled = True
    template_miner = TemplateMiner(persistence, config=config)

    # Create preprocessor for loading data
    preprocessor = Preprocessor(
        length=20,           # Extract sequences of 20 items
        # Do not include a maximum allowed time between events
        timeout=float('inf'),
    )

    # Create DeepLog object
    # output_size - número de chaves diferentes, geralmente output_size = length
    deeplog = DeepLog(
        input_size=1000,  # Number of different events to expect
        hidden_size=64,  # Hidden dimension, we suggest 64
        output_size=1000,  # Number of different events to expect
    )

    if FIRST_TRANING != 'True':
        load_model(deeplog, MODEL_STABLE_VERSION)


    for batch in range(math.ceil(TIME_RANGE/LOKI_BATCH_SIZE)):
        file_name = loki.get_loki_logs(batch)

        if file_name is not None:  # Check if file_name is not None before processing
            drain_parser.proccess_logs_files(template_miner, file_name)
            deep_log_train.train_model(preprocessor, deeplog, file_name)
            deep_log_predict.model_predict(preprocessor, deeplog, file_name)
        else:
            print(f"No logs found for batch {batch}. Skipping processing.")

    save_model(deeplog, MODEL_STABLE_VERSION)

    aws_tools.sync_data(file_name)

if __name__ == "__main__":
    main()

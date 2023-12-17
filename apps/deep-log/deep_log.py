import aws_tools
import os
import math

import deep_log_train
import deep_log_predict
import drain_parser
import loki
import redis_persistence
from deep_log_metrics import save_model, load_model

from deeplog import DeepLog
from deeplog.preprocessor import Preprocessor
from drain3 import TemplateMiner
from drain3.template_miner_config import TemplateMinerConfig
from drain3.redis_persistence import RedisPersistence
from datetime import datetime, timedelta

REDIS_URL = os.environ['REDIS_URL']
REDIS_PORT = os.environ['REDIS_PORT']
REDIS_KEY = os.environ['REDIS_KEY']
TIME_RANGE = int(os.environ['TIME_RANGE'])
MODEL_STABLE_VERSION = os.environ['MODEL_STABLE_VERSION']
FIRST_TRANING = os.environ['FIRST_TRANING']
LOKI_BATCH_SIZE = int(os.environ["LOKI_BATCH_SIZE"])

persistence = RedisPersistence(
    redis_host=REDIS_URL,
    redis_port=REDIS_PORT,
    redis_db=0,
    redis_pass='',
    is_ssl=False,
    redis_key=REDIS_KEY
)

def generate_time_batches(start_time, end_time, batch_size):
    current_time = start_time
    while current_time < end_time:
        yield current_time
        current_time += timedelta(minutes=batch_size)

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
    deeplog = DeepLog(
        input_size=1000,  # Number of different events to expect
        hidden_size=64,  # Hidden dimension, we suggest 64
        output_size=1000,  # Number of different events to expect
    )

    if FIRST_TRANING != 'True':
        load_model(deeplog, MODEL_STABLE_VERSION)

    redis_client = redis_persistence.get_redis_client()
    last_processed_timestamp = redis_persistence.get_last_processed_timestamp(redis_client)

    start_time = datetime.utcnow() - timedelta(minutes=TIME_RANGE)
    end_time = datetime.utcnow()

    for timestamp in generate_time_batches(start_time, end_time, LOKI_BATCH_SIZE):
        batch_id = int((end_time - timestamp).total_seconds() / LOKI_BATCH_SIZE)
        file_name = loki.get_loki_logs(timestamp)

        if file_name is not None:
            drain_parser.proccess_logs_files(template_miner, file_name)
            deep_log_train.train_model(preprocessor, deeplog, file_name)
            deep_log_predict.model_predict(preprocessor, deeplog, file_name)
            redis_persistence.set_last_processed_timestamp(redis_client, timestamp)
        else:
            print(f"No logs found for timestamp {timestamp}. Skipping processing.")

    save_model(deeplog, MODEL_STABLE_VERSION)

    aws_tools.sync_data(file_name)

if __name__ == "__main__":
    main()

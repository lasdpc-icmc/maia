import os
import drain_parser
from deeplog.preprocessor import Preprocessor
from drain3 import TemplateMiner
from drain3.template_miner_config import TemplateMinerConfig
from datetime import timedelta
from drain3.redis_persistence import RedisPersistence

REDIS_URL = os.getenv("REDIS_URL", "127.0.0.1")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_KEY = os.getenv("REDIS_KEY", "drain3")

persistence = RedisPersistence(
    redis_host=REDIS_URL,
    redis_port=REDIS_PORT,
    redis_db=0,
    redis_pass='',
    is_ssl=False,
    redis_key=REDIS_KEY
)

file_name = "logs/logs.txt"

def generate_time_batches(start_time, end_time, batch_size):
    current_time = start_time
    while current_time < end_time:
        current_time += timedelta(minutes=batch_size)
        yield current_time

def main():
    config = TemplateMinerConfig()
    config.load(os.path.dirname(__file__) + "/drain3.ini")
    config.profiling_enabled = True
    template_miner = TemplateMiner(persistence, config=config)


    preprocessor = Preprocessor(
        length=20,
        timeout=float('inf'),
    )

    drain_parser.proccess_logs_files(template_miner, file_name)

if __name__ == "__main__":
    main()

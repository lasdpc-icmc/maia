from redis import StrictRedis
import os
from datetime import datetime, timedelta

REDIS_PORT = os.environ['REDIS_PORT']
REDIS_URL = os.environ['REDIS_URL']
TIME_RANGE = int(os.environ['TIME_RANGE'])
LOKI_BATCH_SIZE = int(os.environ['LOKI_BATCH_SIZE'])

def get_redis_client():
    return StrictRedis(
        host=REDIS_URL,
        port=REDIS_PORT,
        db=0,
        password='',
        ssl=False
    )

def get_last_processed_timestamp(redis_client, final_timestamp):
    last_timestamp = redis_client.get('last_processed_timestamp')
    return datetime.strptime(last_timestamp.decode('utf-8'), "%Y-%m-%d %H:%M:%S") if last_timestamp is not None else (final_timestamp - timedelta(minutes=TIME_RANGE) - timedelta(minutes=LOKI_BATCH_SIZE))

def set_last_processed_timestamp(redis_client, timestamp):
    redis_client.set('last_processed_timestamp', timestamp.strftime("%Y-%m-%d %H:%M:%S"))

def get_final_timestamp(redis_client):
    final_timestamp = redis_client.get('final_timestamp')
    if final_timestamp is None:
        redis_client.set('final_timestamp', datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        return datetime.now()

    return datetime.strptime(final_timestamp.decode('utf-8'), "%Y-%m-%d %H:%M:%S")

def clear_timestamps(redis_client):
    redis_client.delete('final_timestamp')
    redis_client.delete('last_processed_timestamp')

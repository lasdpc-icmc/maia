from redis import StrictRedis
import os
from datetime import datetime

REDIS_PORT = os.environ['REDIS_PORT']
REDIS_URL = os.environ['REDIS_URL']

def get_redis_client():
    return StrictRedis(
        host=REDIS_URL,
        port=REDIS_PORT,
        db=0,
        password='',
        ssl=False
    )

def get_last_processed_timestamp(redis_client):
    last_timestamp = redis_client.get('last_processed_timestamp')
    return datetime.strptime(last_timestamp.decode('utf-8'), "%Y-%m-%d %H:%M:%S") if last_timestamp is not None else datetime.min

def set_last_processed_timestamp(redis_client, timestamp):
    redis_client.set('last_processed_timestamp', timestamp.strftime("%Y-%m-%d %H:%M:%S"))

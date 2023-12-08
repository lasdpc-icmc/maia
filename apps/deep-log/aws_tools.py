import boto3
import os

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
MODEL_STABLE_VERSION = os.environ['MODEL_STABLE_VERSION']

def upload_to_s3(file_name, s3_path):
    s3 = boto3.resource('s3')
    bucket_name = S3_BUCKET_NAME
    s3_file_path = s3_path + '/' + file_name

    try:
        s3.Bucket(bucket_name).upload_file(file_name, s3_file_path)
        print("Upload successful")
    except Exception as e:
        print("Upload failed:", e)


def get_to_s3(file_name, prefix):
    s3 = boto3.client('s3')
    bucket_name = S3_BUCKET_NAME
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

    last_object = max(response['Contents'], key=lambda x: x['LastModified'])
    last_object_key = last_object['Key']

    s3.download_file(bucket_name, last_object_key, file_name)


def list_s3_files(prefix):
    s3 = boto3.client('s3')
    bucket_name = S3_BUCKET_NAME
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    files = []
    if 'Contents' in response:
        for file in response['Contents']:
            files.append(file['Key'])

    files = [j[6:] for j in files]
    return files

def sync_data (file_name):
    s3_path = "raw"
    upload_to_s3(file_name, s3_path)
    print(f"Upload Raw data '{file_name}' from Loki to S3")

    file_name = file_name[:-4]
    s3_path = "deep_log"
    upload_to_s3(f'{file_name}_predict.json', s3_path)
    print(f"Upload Predicit data '{file_name}_predict.json' to S3")

    s3_path = "clean"
    upload_to_s3(f'{file_name}_cleansed.json', s3_path)
    print(f"Upload cleansed data '{file_name}_cleansed.json' to S3")

    s3_path = "deeplog_statemodel"
    upload_to_s3(MODEL_STABLE_VERSION, s3_path)
    print(f"Deeplog Model '{MODEL_STABLE_VERSION}' to S3")

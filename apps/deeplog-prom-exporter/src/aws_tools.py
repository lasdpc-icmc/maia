import boto3
import os
import json


def get_file_s3(file_name, prefix):
    s3 = boto3.client('s3')
    bucket_name = os.environ["S3_BUCKET_NAME"]

    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

    # Get the last object (i.e., the one with the most recent upload time)
    last_object = max(response['Contents'], key=lambda x: x['LastModified'])
    last_object_key = last_object['Key']

    # Download the file to the download directory
    s3.download_file(bucket_name, last_object_key, file_name)


def get_json_s3(prefix):
    get_file_s3("in", prefix)

    f = open("in", "r")
    jsonin = json.load(f)
    f.close()
    
    return jsonin

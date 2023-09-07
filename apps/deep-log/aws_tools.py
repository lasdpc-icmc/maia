import boto3
import os

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']

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

    # List all objects in the 'raw/' prefix of the bucket
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

    # Get the last object (i.e., the one with the most recent upload time)
    last_object = max(response['Contents'], key=lambda x: x['LastModified'])
    last_object_key = last_object['Key']

    # Download the file to the download directory
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



import boto3
import os
import shutil

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    source = os.getenv('source')
    file_name = event['Records'][0]['s3']['object']['key']
    s3.meta.client.download_file(source, file_name, f'/tmp/{file_name}')

    original = fr'/tmp/{file_name}'
    target = fr'\\\\ec2-44-203-144-203.compute-1.amazonaws.com\\C:\\{file_name}'

    shutil.copyfile(original, target)
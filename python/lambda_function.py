import boto3
import os

datasync = boto3.client('datasync', region_name='us-east-1')

def lambda_handler(event, context):
    task_arn = os.getenv('task_arn')
    datasync.start_task_execution(TaskArn=f"{task_arn}")
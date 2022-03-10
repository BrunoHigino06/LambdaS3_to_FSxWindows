import boto3
import os

datasync = boto3.client('datasync', region_name='us-east-1')

def lambda_handler(event, context):
    datasync.start_task_execution(TaskArn='arn:aws:datasync:us-east-1:YOUR_USER_ID:task/YOUR_TASK_ID')
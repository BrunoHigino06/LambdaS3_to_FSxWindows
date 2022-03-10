import boto3

datasync = boto3.client('datasync', region_name='YOUR_REGION')

def lambda_handler(event, context):
    datasync.start_task_execution(TaskArn='arn:aws:datasync:YOUR_REGION:YOUR_USER_ID:task/YOUR_TASK_ID')
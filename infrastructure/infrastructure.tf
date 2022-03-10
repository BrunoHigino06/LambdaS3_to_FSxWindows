# S3 source and destination

resource "aws_s3_bucket" "SourceBucket" {
  bucket = "sourcebucket20220507"
  force_destroy = true
  
  tags = {
    "name" = "SourceBucket"
  }

}

resource "aws_s3_bucket_acl" "SourceBucketACL" {
  bucket = aws_s3_bucket.SourceBucket.id
  acl    = "private"
}

# EFS FileS

resource "aws_efs_file_system" "FileServer" {
  creation_token = "FileServer"

  tags = {
    Name = "FileServer"
  }
}

# EFS Mount Target

resource "aws_efs_mount_target" "MountEast1a" {
  file_system_id = aws_efs_file_system.FileServer.id
  subnet_id      = var.aws_efs_mount_target_MountEast1a_subnet_id_var
  security_groups = [var.aws_efs_mount_target_MountEast1a_security_groups_var]
}

# DataSync 

# DataSync Locations

resource "aws_datasync_location_s3" "SourceS3" {
  s3_bucket_arn = aws_s3_bucket.SourceBucket.arn
  subdirectory  = "/"

  s3_config {
    bucket_access_role_arn = var.aws_datasync_location_s3_SourceS3_bucket_access_role_arn_var
  }
}

resource "aws_datasync_location_efs" "DestEFS" {

  efs_file_system_arn = aws_efs_mount_target.MountEast1a.file_system_arn

  ec2_config {
    security_group_arns = [var.aws_datasync_location_efs_DestEFS_security_group_arns_var]
    subnet_arn          = var.aws_datasync_location_efs_DestEFS_subnet_arn_var
  }
}

resource "aws_datasync_task" "S3ToEFSTask" {
  destination_location_arn = aws_datasync_location_efs.DestEFS.arn
  name                     = "S3ToEFSTask"
  source_location_arn      = aws_datasync_location_s3.SourceS3.arn

  options {
    bytes_per_second = -1
  }
  depends_on = [
    aws_datasync_location_efs.DestEFS,
    aws_datasync_location_s3.SourceS3
  ]
}

# Lambda Function

resource "aws_lambda_function" "S3ToEFS" {
  filename      = "./python/lambda_function.zip"
  function_name = "S3ToEFS"
  role          = var.aws_lambda_function_S3ToEFS_role_var
  source_code_hash = filebase64sha256("./python/lambda_function.zip")
  handler = "lambda_function.lambda_handler"

  runtime = "python3.8"

  environment {
    variables = {
      task_arn = aws_datasync_task.S3ToEFSTask.arn
    }
  }

  tags = {
    "name" = "S3ToEFS"
  }

  depends_on = [
    aws_efs_file_system.FileServer,
    aws_datasync_task.S3ToEFSTask,
    aws_s3_bucket.SourceBucket
  ]
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.S3ToEFS.function_name}"
  retention_in_days = 14
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.SourceBucket.bucket
  lambda_function {
    lambda_function_arn = aws_lambda_function.S3ToEFS.arn
    events              = ["s3:ObjectCreated:*"]

  }

  depends_on = [
    aws_lambda_function.S3ToEFS,
    aws_s3_bucket.SourceBucket
  ]
}
resource "aws_lambda_permission" "LambdaS3Acess" {
  statement_id  = "LambdaS3Acess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.S3ToEFS.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.SourceBucket.id}"
  
  depends_on = [
    aws_lambda_function.S3ToEFS,
    aws_s3_bucket.SourceBucket
  ]
}
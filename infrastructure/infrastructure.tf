# S3 source and destination

resource "aws_s3_bucket" "SourceBucket" {
  bucket = "sourcebucket20220307"
  force_destroy = true
  
  tags = {
    "name" = "SourceBucket"
  }

}

resource "aws_s3_bucket_acl" "SourceBucketACL" {
  bucket = aws_s3_bucket.SourceBucket.id
  acl    = "private"
}


# Lambda Function

resource "aws_lambda_function" "S3ToS3" {
  filename      = "./python/lambda_function.zip"
  function_name = "S3ToS3"
  role          = var.aws_lambda_function_S3ToS3_role_var
  source_code_hash = filebase64sha256("./python/lambda_function.zip")
  handler = "lambda_function.lambda_handler"

  runtime = "python3.8"

  environment {
    variables = {
      source = aws_s3_bucket.SourceBucket.bucket
    }
  }

  tags = {
    "name" = "S3ToS3"
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.S3ToS3.function_name}"
  retention_in_days = 14
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.SourceBucket.bucket
  lambda_function {
    lambda_function_arn = aws_lambda_function.S3ToS3.arn
    events              = ["s3:ObjectCreated:*"]

  }

  depends_on = [
    aws_lambda_function.S3ToS3,
    aws_s3_bucket.SourceBucket
  ]
}
resource "aws_lambda_permission" "LambdaS3Acess" {
  statement_id  = "LambdaS3Acess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.S3ToS3.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.SourceBucket.id}"
  
  depends_on = [
    aws_lambda_function.S3ToS3,
    aws_s3_bucket.SourceBucket
  ]
}

resource "tls_private_key" "PrivKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "WindowsKey"
  public_key = tls_private_key.PrivKey.public_key_openssh
  depends_on = [
    tls_private_key.PrivKey
  ]
}

resource "null_resource" "TerraformTag" {
  provisioner "local-exec" {
    command = "echo ${tls_private_key.PrivKey.private_key_pem} > .\\Key.pem"
  }
  depends_on = [
    tls_private_key.PrivKey,
    aws_key_pair.generated_key
  ]
}

resource "aws_instance" "WindowsServer" {
  ami           = "ami-0c19f80dba70861db"
  instance_type = "t2.medium"
  vpc_security_group_ids = [var.aws_instance_WindowsServer_security_groups_var]
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "WindowsServer"
  }

  depends_on = [
    tls_private_key.PrivKey
  ]
}
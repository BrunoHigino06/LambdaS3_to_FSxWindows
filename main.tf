module "iam" {
  source = ".\\iam\\"
  providers = {
    aws = aws.us
  }
}

module "network" {
  source = ".\\network\\"
  providers = {
    aws = aws.us
  }
}

module "infrastructure" {
  source = ".\\infrastructure\\"
  providers = {
    aws = aws.us
  }
  aws_lambda_function_S3ToS3_role_var = module.iam.aws_iam_role_LambdaRole_output
  aws_instance_WindowsServer_security_groups_var = module.network.aws_security_group_EC2SG_id_output
  
  depends_on = [
    module.iam,
    module.network
  ]
}
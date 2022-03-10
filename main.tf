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
  aws_lambda_function_S3ToEFS_role_var = module.iam.aws_iam_role_LambdaRole_output
  aws_instance_WindowsServer_security_groups_var = module.network.aws_security_group_EC2SG_id_output
  aws_datasync_location_s3_SourceS3_bucket_access_role_arn_var = module.iam.aws_iam_role_DataSyncRole_output
  aws_efs_mount_target_MountEast1a_subnet_id_var = module.network.aws_default_subnet_default_az1_subnet_id_output
  aws_datasync_location_efs_DestEFS_security_group_arns_var = module.network.aws_security_group_EC2SG_arn_output
  aws_datasync_location_efs_DestEFS_subnet_arn_var = module.network.aws_default_subnet_default_az1_subnet_arn_output
  aws_efs_mount_target_MountEast1a_security_groups_var = module.network.aws_security_group_EC2SG_id_output
  
  depends_on = [
    module.iam,
    module.network
  ]
}
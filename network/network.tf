resource "aws_default_vpc" "MainVPC" {
  tags = {
    Name = "MainVPC"
  }
}

output "aws_default_vpc_MainVPC_ID_output" {
  value = aws_default_vpc.MainVPC.id
}

resource "aws_security_group" "EC2SG" {
  name        = "EC2SG"
  description = "Allow All traffic"
  vpc_id      = aws_default_vpc.MainVPC.id

  tags = {
    "Name" = "EC2SG"
  }
}

output "aws_security_group_EC2SG_id_output" {
  value = aws_security_group.EC2SG.id
}

resource "aws_security_group_rule" "AllowAllIngress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.EC2SG.id
}

resource "aws_security_group_rule" "AllowAllEgress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.EC2SG.id
}

# Subnet us-east-1a

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

output "aws_default_subnet_default_az1_subnet_id_output" {
  value = aws_default_subnet.default_az1.id
}

output "aws_default_subnet_default_az1_subnet_arn_output" {
  value = aws_default_subnet.default_az1.arn
}
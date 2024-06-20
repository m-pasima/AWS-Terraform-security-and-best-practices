terraform {
  required_version = ">= 0.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Create an IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "terraform-sec-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# Create an IAM Policy
resource "aws_iam_policy" "terraform_policy" {
  name   = "terraform-sec-policy"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# Attach the IAM Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "terraform_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "terraform_profile" {
  name = "terraform-sec-profile-unique"
  role = aws_iam_role.ec2_role.name
}

# Create an EC2 Instance with the IAM Instance Profile
resource "aws_instance" "ec2_profile_instance" {
  ami                  = "ami-07d1e0a32156d0d21"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.terraform_profile.name
  ebs_optimized        = true
  monitoring           = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "Terraform-Profile"
  }
}



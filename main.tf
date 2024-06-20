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

# Create an IAM Policy with specific permissions
resource "aws_iam_policy" "terraform_policy" {
  name   = "terraform-sec-policy"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
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
  name = "terraform-sec-profile"
  role = aws_iam_role.ec2_role.name
}

# Create an EC2 Instance with the IAM Instance Profile
resource "aws_instance" "ec2_profile_instance" {
  ami                  = "ami-0b53285ea6c7a08a7"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.terraform_profile.name

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

# Create an additional EC2 Instance
resource "aws_instance" "terraform" {
  ami           = "ami-0b53285ea6c7a08a7"
  instance_type = "t2.micro"

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "terraform-test"
  }
}

# Create an S3 Bucket with versioning and default server-side encryption
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "secure_sec_config"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "SecureBucket"
  }

  # tfsec:ignore:aws-s3-encryption-customer-key
  # tfsec:ignore:aws-s3-enable-bucket-logging
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}



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


# Create an EC2 Instance with the IAM Instance Profile
resource "aws_instance" "ec2_profile_instance" {
  ami                  = "ami-0b53285ea6c7a08a7"
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



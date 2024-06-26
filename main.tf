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

# Create an EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                  = "ami-0b53285ea6c7a08a7"  # Ensure this AMI ID is valid for the region
  instance_type        = "t2.micro"
 # ebs_optimized        = true
 # monitoring           = true

 # metadata_options {
 #  http_tokens = "required"
 # }

  #root_block_device {
  #  encrypted = true
  #}

  tags = {
    Name = "Terraform-Instance"
  }
}



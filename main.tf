provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "terraform" {
  ami           = "ami-0b53285ea6c7a08a7"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-test"
  }
}

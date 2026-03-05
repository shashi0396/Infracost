provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.medium"

  tags = {
    Environment = "dev"
    Team        = "platform"
    Owner       = "devops"
    CostCenter  = "engineering"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = "ap-south-1a"
  size              = "20"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#creating VPC
data "aws_availability_zones" "available" {}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "terraform_vpc"
  }
}


#Subnet Creation
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.31.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.31.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet2"
  }
}



resource "aws_launch_configuration" "instance_config" {
  name_prefix     = "instance_config"
  image_id        = "ami-051f7e7f6c2f40dc1"
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.allow_traffic_to_asg.id]

}


resource "aws_autoscaling_group" "asg" {
  name_prefix          = "asg"
  launch_configuration = aws_launch_configuration.instance_config.id
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}


#Security Group
resource "aws_security_group" "allow_traffic_to_asg" {
  name        = "allow_traffic_to_asg"
  description = "Allow TLS inbound traffic for asg"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Temporary/Private Traffic "
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#S3 bucket Creation
resource "aws_s3_bucket" "tf-remote-backend-s3-bucket" {
  bucket = "tf-remote-backend-s3-bucket"
}

resource "aws_s3_bucket_versioning" "tf-remote-backend-s3-bucket" {
  bucket = aws_s3_bucket.tf-remote-backend-s3-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}






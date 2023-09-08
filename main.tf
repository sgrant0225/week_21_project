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
  availability_zone = "us-east-1"
  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.31.2.0/24"
  availability_zone = "us-east-1"
  tags = {
    Name = "subnet2"
  }
}



resource "aws_launch_configuration" "instance_config" {
  name_prefix     = "instance_config"
  image_id        = "ami-051f7e7f6c2f40dc1"
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.instance_config.id]

}


resource "aws_autoscaling_group" "autoscaling" {
  name_prefix          = "autoscaling"
  launch_configuration = aws_launch_configuration.instance_config.id
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}













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

resource "aws_launch_configuration" "instance_config" {
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
  vpc_zone_identifier  = 
}











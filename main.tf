provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Techtest = "true"
    }
  }
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
}

resource "aws_subnet" "tf_ingress_snet_az1" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = var.tf_ingress_snet_az1_cidr
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "tf_ingress_snet_az2" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = var.tf_ingress_snet_az2_cidr
  availability_zone = "eu-west-2b"
}

resource "aws_subnet" "tf_private_snet_az1" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = var.tf_private_snet_az1_cidr
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "tf_private_snet_az2" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = var.tf_private_snet_az2_cidr
  availability_zone = "eu-west-2b"
}

resource "aws_security_group" "tf_alb_sg" {
  description = "Allow http traffic"
  vpc_id = aws_vpc.tf_vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      var.tf_private_snet_az1_cidr]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      var.tf_private_snet_az2_cidr]
  }
}

resource "aws_security_group" "tf_webserver_sg" {
  vpc_id = aws_vpc.tf_vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      var.tf_ingress_snet_az1_cidr]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      var.tf_ingress_snet_az2_cidr]
  }
}
resource "aws_alb_target_group" "tf_alb_tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_alb" "tf_alb" {
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.tf_alb_sg.id]
  subnets = [
    aws_subnet.tf_ingress_snet_az1.id,
    aws_subnet.tf_ingress_snet_az2.id]
  enable_deletion_protection = false
}

resource "aws_alb_listener" "tf_alb_lsnr" {
  load_balancer_arn = aws_alb.tf_alb.id
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.tf_alb_tg.id
    type = "forward"
  }
}
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_route_table" "incoming_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
}

resource "aws_route_table_association" "in_rta_az1" {
  count = 2
  subnet_id = aws_subnet.tf_ingress_snet_az1.id
  route_table_id = aws_route_table.incoming_rt.id
}

resource "aws_route_table_association" "in_rta_az2" {
  count = 2
  subnet_id = aws_subnet.tf_ingress_snet_az2.id
  route_table_id = aws_route_table.incoming_rt.id
}

resource "aws_launch_configuration" "tf_lc" {
  image_id = "ami-0ff4c8fb495a5a50d"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.tf_webserver_sg.id]
  user_data = <<-EOF
            #!/bin/bash
            echo "Hello " > index.html
            hostname >> index.html
            nohup busybox httpd -f  &
            EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tf_webserver_asg" {
  launch_configuration = aws_launch_configuration.tf_lc.name
  min_size = 2
  max_size = 3
  vpc_zone_identifier = [
    aws_subnet.tf_private_snet_az1.id,
    aws_subnet.tf_private_snet_az2.id
  ]
  target_group_arns = [
    aws_alb_target_group.tf_alb_tg.id]
  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      "key"                 = "Techtest"
      "value"               = "true"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "mykey2"
      "value"               = var.mykey2
      "propagate_at_launch" = true
    },
  ]
}

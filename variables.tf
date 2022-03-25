variable "aws_region" {
  default = "eu-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "tf_ingress_snet_az1_cidr" {
  default = "10.0.1.0/24"
}

variable "tf_ingress_snet_az2_cidr" {
  default = "10.0.2.0/24"
}

variable "tf_private_snet_az1_cidr" {
  default = "10.0.3.0/24"
}

variable "tf_private_snet_az2_cidr" {
  default = "10.0.4.0/24"
}

variable "mykey2" {
  
}
variable "instance_type" {
  description = "instance type for the ec2 instance"
  type = string
  default = "t2.micro"
}

variable "private_subnet_ids" {
  description = "ids of the private subnets"
}

variable "vpc_cidr" {
  description = "cidr of vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "id of vpc"
  type = string
}
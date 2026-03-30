variable "app_port" {
  description = "port of the application"
  type = number
  default = 8080
}

variable "vpc_id" {
  description = "id of the vpc"
  type = string
}

variable "public_subnet_ids" {
  description = "ids of the public subnetys"
  type = list(string)
}

variable "ecs_sg_alb" {
  description = "sg for the alb"
  type = string
}
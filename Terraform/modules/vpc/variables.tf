variable "vpc_cidr" {
  description = "vpc cidr"
  type = string
  default = "10.0.0.0/16"
}

variable "region" {
  description = "region"
  type = string
  default = "eu-north-1"
}

variable "public_cidr" {
  description = "cidr for public traffic"
  type = string
  default = "0.0.0.0/0"
}

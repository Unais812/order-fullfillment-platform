variable "allow_all_traffic_cidr" {
  description = "cidr for all internet access"
  type = string
  default = "0.0.0.0/0"
}

variable "vpc_id" {
  description = "vpc id"
  type = string
}
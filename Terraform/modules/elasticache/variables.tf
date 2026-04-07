variable "private_subnet_ids" {
  description = "ids of the private subnets"
  type = list(string)
}

variable "redis_sg" {
  description = "sg for elasticache"
  type = string
}
variable "domain_name" {
  description = "The name of my domain"
  type = string
  default = "nginxunais.com"
}

variable "zone_id" {
    description = "id of my hosted zone"
    type = string
    default = "Z08062433SPGWTOR9FA3E"
}

variable "record_name" {
    description = "name of the record in route53"
    type = string
    default = "orderplatform.nginxunais.com"
}

variable "record_type" {
  description = "type of the record"
  type = string
  default = "A"
}

variable "alb_dns" {
  description = "DNS name of the ALB"
  type = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type = string
}
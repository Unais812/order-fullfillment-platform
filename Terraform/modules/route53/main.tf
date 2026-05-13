data "aws_route53_zone" "app_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "ecsv3_record" {
  zone_id = data.aws_route53_zone.app_zone.id
  name    = var.record_name
  type    = var.record_type
  
  alias {
    name = var.alb_dns
    zone_id = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.app_zone.zone_id
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  subject_alternative_names = [var.record_name, var.domain_name]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true # replaces a cert which may currently be in use 
  }
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  depends_on = [ aws_route53_record.ecsv3_record ]
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}
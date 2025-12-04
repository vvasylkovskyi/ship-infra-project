resource "aws_route53_record" "www" {
  zone_id = var.main_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60
  records = [var.dns_record]
}
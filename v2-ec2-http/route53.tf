resource "aws_route53_zone" "main" {
  name = "viktorvasylkovskyi.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.viktorvasylkovskyi.com"
  type    = "A"
  ttl     = 60
  records = [aws_eip.my_app.public_ip]
}
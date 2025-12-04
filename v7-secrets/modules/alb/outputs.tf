output "dns_name" {
    value = aws_lb.my_app.dns_name
}

output "zone_id" {
    value = aws_lb.my_app.zone_id
}
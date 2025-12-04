output "ec2_first_instance_ip_address" {
  value       = module.ec2_first_instance.public_ip
  description = "The Elastic IP address allocated to the first EC2 instance."
}

output "ec2_second_instance_ip_address" {
  value       = module.ec2_second_instance.public_ip
  description = "The Elastic IP address allocated to the second EC2 instance."
}

output "database_endpoint" {
  value       = module.rds.database_endpoint
  description = "The connection endpoint for the Postgres database."
}
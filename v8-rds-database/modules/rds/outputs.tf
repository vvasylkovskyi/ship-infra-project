output "database_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "The connection endpoint for the Postgres database."
}
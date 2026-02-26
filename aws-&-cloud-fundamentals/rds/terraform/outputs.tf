output "rds_endpoint" {
  value       = aws_db_instance.rds.endpoint
  description = "The connection endpoint for the RDS instance"
}

output "rds_address" {
  value       = aws_db_instance.rds.address
  description = "The hostname of the RDS instance"
}

output "rds_port" {
  value       = aws_db_instance.rds.port
  description = "The port on which the DB accepts connections"
}

output "database_name" {
  value       = aws_db_instance.rds.db_name
  description = "The name of the default database"
}

output "aws_region" {
  value = var.aws_region
}

output "connection_string" {
  value       = "postgresql://${var.master_username}:${var.master_password}@${aws_db_instance.rds.endpoint}/${var.database_name}"
  description = "PostgreSQL connection string"
  sensitive   = true
}

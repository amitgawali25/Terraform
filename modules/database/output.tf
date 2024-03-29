output "db_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}

output "db_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.db_instance.address
  sensitive   = true
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.db_instance.port
  sensitive   = true
}

output "db_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.db_instance.username
  sensitive   = true
}
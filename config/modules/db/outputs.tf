output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.db.address
}


output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.db.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.db.endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.db.db_name
}
output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.db.port
}

output "db_instance_engine" {
  description = "The engine of the RDS instance"
  value       = aws_db_instance.db.engine
}

output "db_instance_vpc_security_group_ids" {
  description = "The security group IDs of the RDS instance"
  value       = aws_db_instance.db.vpc_security_group_ids
}

output "db_subnet_group_name" {
  description = "The name of the RDS instance's subnet group"
  value       = aws_db_instance.db.db_subnet_group_name
}

output "db_maintenance_window" {
  description = "The maintenance window of the RDS instance"
  value       = aws_db_instance.db.maintenance_window
}

output "db_backup_retention_period" {
  description = "The backup retention period"
  value       = aws_db_instance.db.backup_retention_period
}

output "db_backup_window" {
  description = "The backup window of the RDS instance"
  value       = aws_db_instance.db.backup_window
}

output "rds_parameter_group_name" {
  description = "The name of the RDS parameter group"
  value       = aws_db_parameter_group.rds_postgres.name
}

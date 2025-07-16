output "db_instance_endpoint" {
  value       = try(aws_db_instance.rds_instance[0].endpoint, null)
  description = "RDS DB instance endpoint"
}

output "db_instance_id" {
  value       = try(aws_db_instance.rds_instance[0].id, null)
  description = "RDS DB instance ID"
}

output "rds_proxy_endpoint" {
  value       = try(aws_db_proxy.rds_db_proxy[0].endpoint, null)
  description = "RDS Proxy endpoint"
}

output "rds_proxy_name" {
  value       = try(aws_db_proxy.rds_db_proxy[0].name, null)
  description = "RDS Proxy name"
}

output "rds_cluster_endpoint" {
  value       = try(aws_rds_cluster.rds_cluster[0].endpoint, null)
  description = "RDS cluster writer endpoint"
}

output "rds_cluster_reader_endpoint" {
  value       = try(aws_rds_cluster.rds_cluster[0].reader_endpoint, null)
  description = "RDS cluster reader endpoint"
}

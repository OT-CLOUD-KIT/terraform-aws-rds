output "db_instance_endpoint" {
  value = aws_db_instance.default.address
}
output "db_instance_port" {
  value = aws_db_instance.default.port
}

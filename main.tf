/*-------------------------------------------------------*/
resource "aws_db_instance" "default" {
  identifier             = var.name
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot    = var.skip_final_snapshot
  parameter_group_name   = aws_db_parameter_group.parameter_group.id
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.id
}
/*-------------------------------------------------------*/
resource "aws_db_parameter_group" "parameter_group" {
  name   = "${var.name}-parameter-group"
  family = "${var.engine}${var.engine_version}"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
/*-------------------------------------------------------*/
resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.name}_subnet_group"
  subnet_ids = var.subnet_ids
}

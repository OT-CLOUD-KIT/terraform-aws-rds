/*-------------------------------------------------------*/
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier           = var.cluster_identifier #"devcluster"
  database_name                = var.database_name
  master_username              = var.master_username
  master_password              = var.master_password
  backup_retention_period      = var.backup_retention_period #14
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window #"sat:15:00-sat:16:00"
  engine                       = var.engine #"aurora-mysql"
  engine_version               = var.engine_version 
  db_subnet_group_name         = aws_db_subnet_group.subnet_group.id
  final_snapshot_identifier    = "${var.environment_name}-${var.engine}-cluster"
  vpc_security_group_ids       = var.vpc_security_group_ids
  availability_zones           = var.availability_zones
  snapshot_identifier          = var.snapshot_identifier
  skip_final_snapshot          = var.skip_final_snapshot #true


  tags {
    Name        = "${var.environment_name}-${var.engine}-DB-Cluster"
    VPC         = var.vpc_name
    ManagedBy   = "Terraform"
    Environment = var.environment_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
/*-------------------------------------------------------*/
resource "aws_db_subnet_group" "subnet_group" {
  name          = "${var.cluster_identifier}_subnet_group"
  description   = "Allowed subnets for ${var.environment_name}-${var.engine}-DB-Cluster instances"
  subnet_ids    = var.subnet_ids
  
  tags {
    Name        = "${var.environment_name}-${var.engine}-DB-Cluster"
    VPC         = var.vpc_name
    ManagedBy   = "Terraform"
    Environment = var.environment_name
  }
}
/*-------------------------------------------------------*/
resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count                = var.count #1
  identifier           = "${var.environment_name}-aurora-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = var.instance_class
  engine               = var.engine #"aurora-mysql"
  engine_version       = var.engine_version #"5.7.12"
  db_subnet_group_name = aws_db_subnet_group.subnet_group.id
  publicly_accessible  = var.publicly_accessible #false
  

  tags {
    Name        = "${var.environment_name}-${var.engine}-DB-Cluster"
    VPC         = var.vpc_name
    ManagedBy   = "Terraform"
    Environment = var.environment_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
/*-------------------------------------------------------*/
# resource "aws_db_parameter_group" "parameter_group" {
#   name   = "${var.name}-parameter-group"
#   family = "${var.engine}${var.engine_version}"

#   parameter {
#     name  = "character_set_server"
#     value = "utf8"
#   }

#   parameter {
#     name  = "character_set_client"
#     value = "utf8"
#   }
# }
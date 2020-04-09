/*-------------------------------------------------------*/
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier           = var.cluster_identifier 
  database_name                = var.database_name
  master_username              = var.master_username
  master_password              = var.master_password
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window 
  preferred_maintenance_window = var.preferred_maintenance_window
  engine                       = var.engine 
  engine_version               = var.engine_version 
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.id
  final_snapshot_identifier    = "${var.environment_name}-aurora-cluster"
  vpc_security_group_ids       = var.vpc_security_group_ids
  availability_zones           = var.availability_zones
  skip_final_snapshot          = var.skip_final_snapshot #true
  #snapshot_identifier         = var.snapshot_identifier

  tags = {
    Name        = "${var.environment_name}-Aurora-DB-Cluster"
    VPC         = var.vpc_name
    ManagedBy   = "terraform"
    Environment = var.environment_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*-------------------------------------------------------*/

resource "aws_db_subnet_group" "db_subnet_group" {
  name                        = "${var.environment_name}-aurora-db-subnet-group"
  description                 = "Allowed subnets for Aurora DB cluster instances"
  subnet_ids                  = var.subnet_ids

  tags = {
    Name        = "${var.environment_name}-Aurora-DB-Subnet-Group"
    VPC         = var.vpc_name
    ManagedBy   = "terraform"
    Environment = var.environment_name
  }
}

/*-------------------------------------------------------*/

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count                       = var.count_rds
  identifier                  = "${var.environment_name}-aurora-instance-${count.index}"
  cluster_identifier          = aws_rds_cluster.aurora_cluster.id
  instance_class              = var.instance_type
  engine                      = var.engine
  engine_version              = var.engine_version 
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible         = var.publicly_accessible

  tags = {
    Name        = "${var.environment_name}-Aurora-DB-Instance-${count.index}"
    VPC         = var.vpc_name
    ManagedBy   = "terraform"
    Environment = var.environment_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
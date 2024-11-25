resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = "${var.environment}-${var.rds_cluster_name}"
  engine                          = var.db_engine
  engine_version                  = var.engine_version
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = "arn:aws:kms:ap-south-1:442042533290:key/1f234c78-3f55-4450-be6a-99b063a90ff6"
  database_name                   = var.restore_rds_from_snapshot ? null : "DB${random_string.schema_suffix.result}"
  master_username                 = var.restore_rds_from_snapshot ? null : local.rds_master_user_credentials.username
  master_password                 = var.restore_rds_from_snapshot ? null : local.rds_master_user_credentials.password
  db_subnet_group_name            = aws_db_subnet_group.BuildRDSSubnetGroup.name
  vpc_security_group_ids          = [var.rds_security_group_id]  # Set on the cluster itself
  backup_retention_period         = var.backup_retention_period
  db_cluster_parameter_group_name = var.cluster_parameter_group_name
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  port                            = var.port != "" ? var.port : (var.db_engine == "aurora-mysql" ? 5432 : 3306)
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  final_snapshot_identifier       = "${var.final_snapshot_identifier_prefix}-${var.rds_cluster_name}-${random_id.snapshot_identifier.hex}"

  snapshot_identifier             = var.restore_rds_from_snapshot ? var.snapshot_identifier : null

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []
    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  # Set availability zones explicitly if needed
  availability_zones = ["ap-south-1a"] # Specify the AZ you want to use for the cluster
  
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.rds_cluster_name}"
  })
}

resource "aws_rds_cluster_instance" "rds_instances" {
  count = var.cluster_instance_count
  depends_on = [aws_rds_cluster.rds_cluster]

  engine                          = var.db_engine
  engine_version                  = var.engine_version
  identifier                      = "${var.environment}-${var.instances_identifier}-${count.index}"
  cluster_identifier              = aws_rds_cluster.rds_cluster.cluster_identifier
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  instance_class                  = "db.r5d.large"
  db_parameter_group_name         = var.db_parameter_group_name  # Reference to the DB parameter group variable
  db_subnet_group_name            = aws_db_subnet_group.BuildRDSSubnetGroup.name
  promotion_tier                  = count.index + 1
  apply_immediately               = var.apply_immediately

  # Enhanced monitoring
  monitoring_interval             = var.enhanced_monitoring_role_enabled ? var.monitoring_interval : 0
  monitoring_role_arn             = var.enhanced_monitoring_role_enabled ? aws_iam_role.rds_enhanced_monitoring[0].arn : ""

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? var.performance_insights_kms_key_id : ""
  # Force the instance into a single AZ
  availability_zone      = "ap-south-1a" # Choose the desired AZ for your instance

  # No need to set security groups here, inherited from the cluster
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.instances_identifier}-${count.index}"
  })
}

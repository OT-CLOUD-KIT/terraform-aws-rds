#-----------------------
# AWS resources
#-----------------------
locals {
  DbEngine                 = "aurora-mysql"
  RdsVersion               = "5.7.mysql_aurora.2.03.2"
  RdsParameterGroup        = "aurora-mysql5.7"
  NumClusterInstances      = 2
  EncryptRds               = true
  #RdsCmkId                 = module.rds_kms_key.key_arn
  RdsInstanceType          = "db.r5.xlarge"
  DbParameterGroupTemplate = "Aurora-RDS-Parameter-Group"
  monitoring_interval      = 10
  db-port                  = "3306"
}

resource "aws_security_group" "rds_security_group" {
  name        = "mysql-${var.kubernetes_nickname}-security-group"
  description = "Allow Internal access to RDS"
  vpc_id      = local.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block, "172.16.0.0/12"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}rds_cluster_sg"
  })
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = "${var.environment}-${var.rds_cluster_name}"
  engine                          = var.db_engine
  engine_version                  = var.engine_version
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.storage_encrypted == "true" ? module.rds_kms_key[0].key_arn : ""
  database_name                   = "DB${random_string.schema_suffix.result}"
  master_username                 = local.rds_master_user_credentials.username
  master_password                 = local.rds_master_user_credentials.password
  db_subnet_group_name            = aws_db_subnet_group.BuildRDSSubnetGroup.name
  vpc_security_group_ids          = [aws_security_group.rds_security_group.id]
  backup_retention_period         = var.backup_retention_period
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_ClusterParameterGroup.name
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately                   = var.apply_immediately
  port                             = var.port == "" ? (var.db_engine == "aurora-postgresql" ? 5432 : 3306) : var.port
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  final_snapshot_identifier       = "${var.final_snapshot_identifier_prefix}-${var.rds_cluster_name}-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  snapshot_identifier             = var.restore_rds_from_snapshot == "true" ? var.snapshot_identifier : null
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
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.rds_cluster_name}"
  })
}

resource "aws_rds_cluster_instance" "rds_instances" {
  count = var.cluster_instance_count
  depends_on = [ aws_rds_cluster.rds_cluster]

  engine                          = var.db_engine
  engine_version                  = var.engine_version
  identifier                 = "${var.environment}-${var.instances_identifier}-${count.index}"
  cluster_identifier         = aws_rds_cluster.rds_cluster.cluster_identifier
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  instance_class             = var.instance_class
  db_parameter_group_name    = aws_db_parameter_group.rds_ParameterGroup.name
  db_subnet_group_name       = aws_db_subnet_group.BuildRDSSubnetGroup.name
  promotion_tier             = try(lookup("aurora-mysql-${var.kubernetes_nickname}-${count.index}", "instance_promotion_tier"), count.index + 1)
  apply_immediately               = var.apply_immediately

  # Enhanced monitoring
  monitoring_interval = var.enhanced_monitoring_role_enabled == "true" ? var.monitoring_interval : 0
  monitoring_role_arn = var.enhanced_monitoring_role_enabled == "true" ? aws_iam_role.rds_enhanced_monitoring[0].arn : ""

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled == "true" ? var.performance_insights_kms_key_id : ""

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.instances_identifier}-${count.index}"
  })

}


resource "aws_rds_cluster_parameter_group" "rds_ClusterParameterGroup" {
  name        = "aurora-mysql57"
  family      = "aurora-mysql5.7"
  description = "Parameter group for RDS instances."

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  # parameter {
  #   name  = "character_set_server"
  #   value = "utf8mb4"
  # }

  # parameter {
  #   name  = "character_set_client"
  #   value = "utf8mb4"
  # }

  # parameter {
  #   name  = "character_set_connection"
  #   value = "utf8mb4"
  # }

  # parameter {
  #   name  = "character_set_database"
  #   value = "utf8mb4"
  # }

  # parameter {
  #   name  = "character_set_results"
  #   value = "utf8mb4"
  # }

  # parameter {
  #   name  = "collation_connection"
  #   value = "utf8_unicode_ci"
  # }

  # parameter {
  #   name  = "collation_server"
  #   value = "utf8mb4_unicode_ci"
  # }

  # parameter {
  #   name  = "tx_isolation"
  #   value = "READ-COMMITTED"
  # }

  # parameter {
  #   name  = "max_connections"
  #   value = "1000"
  # }

  # parameter {
  #   name  = "general_log"
  #   value = "1"
  # }

  # parameter {
  #   name  = "long_query_time"
  #   value = "4"
  # }

  # parameter {
  #   name  = "server_audit_logging"
  #   value = "1"
  # }

  # parameter {
  #   name  = "server_audit_logs_upload"
  #   value = "1"
  # }

  # parameter {
  #   name  = "slow_query_log"
  #   value = "1"
  # }

  # parameter {
  #   name  = "server_audit_events"
  #   value = "CONNECT, QUERY, QUERY_DCL, QUERY_DDL, QUERY_DML, TABLE"
  # }

  # parameter {
  #   name  = "log_slow_admin_statements"
  #   value = "1"
  # }

  # parameter {
  #   name  = "log_slow_slave_statements"
  #   value = "1"
  # }
}

resource "aws_db_parameter_group" "rds_ParameterGroup" {
  name        = "aurora-mysql57"
  family      = "aurora-mysql5.7"
  description = "Parameter group for RDS instances."

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
  # parameter {
  #   name  = "tx_isolation"
  #   value = "READ-COMMITTED"
  # }

  #   parameter {
  #   name  = "general_log"
  #   value = "1"
  # }

  # parameter {
  #   name  = "long_query_time"
  #   value = "4"
  # }

  # parameter {
  #   name  = "slow_query_log"
  #   value = "1"
  # }

  # parameter {
  #   name  = "log_slow_admin_statements"
  #   value = "1"
  # }

  # parameter {
  #   name  = "log_slow_slave_statements"
  #   value = "1"
  # }
}


data "aws_kms_key" "by_alias" {
  key_id = "alias/aws/rds"
}
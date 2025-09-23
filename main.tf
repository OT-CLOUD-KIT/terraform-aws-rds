
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "${local.base_name}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    { Name = "${local.base_name}-rds-subnet-group" },
    local.common_tags
  )
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  count       = var.is_cluster ? 0 : 1
  name        = "${local.base_name}-rds-param-group"
  family      = var.parameter_family
  description = "Parameter group for RDS instance"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = merge(
    { Name = "${local.base_name}-rds-param-group" },
    local.common_tags
  )
}

resource "aws_rds_cluster_parameter_group" "rds_cluster_parameter_group" {
  count       = var.is_cluster ? 1 : 0
  name        = "${local.base_name}-rds-cluster-param-group"
  family      = var.parameter_family
  description = "Parameter group for RDS Cluster"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    { Name = "${local.base_name}-rds-cluster-param-group" },
    local.common_tags
  )
}

resource "aws_db_instance" "rds_instance" {
  count                           = var.is_cluster ? 0 : 1
  identifier                      = "${local.base_name}-rds-instance"
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  multi_az                        = var.multi_az
  db_name                         = var.db_name
  username                        = var.username
  password                        = var.password
  port                            = var.port
  vpc_security_group_ids          = var.rds_security_group_id != "" ? [var.rds_security_group_id] : null
  db_subnet_group_name            = aws_db_subnet_group.rds_subnet.name
  parameter_group_name            = aws_db_parameter_group.rds_parameter_group[0].name
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = "${local.base_name}-final-snapshot"
  apply_immediately               = var.apply_immediately
  backup_retention_period         = var.backup_retention_period
  maintenance_window              = var.maintenance_window
  backup_window                   = var.backup_window
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.enhanced_monitoring_role_enabled ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id != "" ? var.kms_key_id : null
  deletion_protection             = var.deletion_protection

  tags = merge(
    { Name = "${local.base_name}-rds-instance" },
    local.common_tags
  )
}

resource "aws_rds_cluster" "rds_cluster" {
  count                                 = var.is_cluster ? 1 : 0
  cluster_identifier                    = "${local.base_name}-rds-cluster"
  engine                                = var.engine
  engine_version                        = var.engine_version
  database_name                         = var.db_name
  master_username                       = var.username
  master_password                       = var.password
  db_subnet_group_name                  = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids                = [var.rds_security_group_id]
  db_cluster_parameter_group_name       = aws_rds_cluster_parameter_group.rds_cluster_parameter_group[0].name
  skip_final_snapshot                   = var.skip_final_snapshot
  final_snapshot_identifier             = "${local.base_name}-final-snapshot"
  apply_immediately                     = var.apply_immediately
  backup_retention_period               = var.backup_retention_period
  preferred_maintenance_window          = var.maintenance_window
  preferred_backup_window               = var.backup_window
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  storage_encrypted                     = var.storage_encrypted
  kms_key_id                            = var.kms_key_id != "" ? var.kms_key_id : null
  deletion_protection                   = var.deletion_protection

  tags = merge(
    { Name = "${local.base_name}-rds-cluster" },
    local.common_tags
  )
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                           = var.is_cluster ? var.cluster_instance_count : 0
  identifier                      = "${local.base_name}-rds-cluster-${count.index}"
  cluster_identifier              = aws_rds_cluster.rds_cluster[0].id
  engine                          = var.engine
  instance_class                  = var.instance_class
  db_subnet_group_name            = aws_db_subnet_group.rds_subnet.name
  apply_immediately               = var.apply_immediately
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.enhanced_monitoring_role_enabled ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  promotion_tier                  = count.index + 1

  tags = merge(
    { Name = "${local.base_name}-rds-cluster-${count.index}" },
    local.common_tags
  )
}

resource "aws_db_proxy" "rds_db_proxy" {
  count                  = var.enable_rds_proxy ? 1 : 0
  name                   = "${local.base_name}-rds-proxy"
  engine_family          = "MYSQL"
  role_arn               = aws_iam_role.rds_proxy_role[0].arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [var.rds_security_group_id]

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = var.rds_proxy_secrets_arn
    iam_auth    = "DISABLED"
  }

  require_tls = false

  tags = merge(
    { Name = "${local.base_name}-rds-proxy" },
    local.common_tags
  )
}

resource "aws_iam_role" "rds_proxy_role" {
  count              = var.enable_rds_proxy ? 1 : 0
  name               = "${local.base_name}-rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_trust.json
}

data "aws_iam_policy_document" "rds_proxy_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count              = var.enhanced_monitoring_role_enabled && var.monitoring_interval > 0 ? 1 : 0
  name               = "${local.base_name}-rds-enhanced-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.enhanced_monitoring_role_enabled && var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

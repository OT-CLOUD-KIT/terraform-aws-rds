variable "environment" {
  default = "prod"

}
variable "secret_manager_name" {
  description = "This name will be used as prefix for all the created resources"
  default     = "rds-db-secret-manager-1"
}

variable "secret_description" {
  description = "This field is the description for the secret manager object"
  default     = "secret manager for mysql/aurora"
}

variable "secret_rotation_days" {
  default     = 30
  description = "How often in days the secret will be rotated"
}

variable "filename" {
  default = "rotate-code-mysql"
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
  type        = string
  default     = "final"
}

variable "restore_rds_from_snapshot" {
  description = "If value is true, it is required to provide snapshot arn to TF_VAR_snapshot_identifier otherwise, leave it blank"
  default     = false
}

variable "snapshot_identifier" {
  description = "Required, when TF_VAR_restore_rds_from_snapshot is set to true"
  default     = null
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = [
    # {
    #   name         = "character_set_client"
    #   value        = "utf8"
    #   apply_method = "pending-reboot"
    # }
  ]
  description = "List of DB cluster parameters to apply"
}

variable "instance_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = [
    # {
    #   name         = "tx_isolation"
    #   value        = "READ-COMMITTED"
    #   apply_method = "pending-reboot"
    # }
  ]
  description = "List of DB instance parameters to apply"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery"
  #default     = ["audit", "general", "slowquery", "error"]
  default = [ "postgresql" ]
}

variable "enhanced_monitoring_role_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring"
  default     = true
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = ""
}

variable "storage_encrypted" {
  description = "Specifies whether the underlying storage layer should be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key if one is set to the cluster"
  type        = string
  default     = ""
}

variable "customer_managed_kms_key" {
  type    = bool
  default = true
}

variable "rds_cluster_name" {
  description = "Name used across resources created"
  type        = string
  default     = "rds-cluster"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 10
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 2
}

variable "db_parameter_group_name" {
  description = "Name for DB Parameter group name"
  type        = string
  default     = "postgresql11"
}

variable "db_parameter_family_name" {
  description = "Name for DB Parameter group name"
  type        = string
  default     = "aurora-postgresql11"
}

variable "cluster_parameter_family_name" {
  description = "Name for DB Parameter group name"
  type        = string
  default     = "aurora-postgresql11"
}

variable "cluster_parameter_group_name" {
  description = "Name for DB Parameter group name"
  type        = string
  default     = "postgresql11"
}



variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "db_engine" {
  description = "Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora database engine version"
  type        = string
  default     = "11.9"
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = ""
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = false
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported"
  type        = bool
  default     = false
}

variable "iam_roles" {
  description = "A List of ARNs for the IAM roles to associate to the RDS Cluster"
  type        = list(string)
  default     = []
}

variable "s3_import" {
  description = "Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = null
}

variable "instance_class" {
  description = "The instance class to use. For details on CPU and memory"
  type        = string
  default     = "db.r5.xlarge"
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}

variable "cluster_instance_count" {
  type        = number
  default     = 2
  description = "Number of DB instances to create in the cluster"
}

variable "instances_identifier" {
  description = "The identifier for the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
  default     = "test"
}

variable "replica_scale_enabled" {
  description = "Whether to enable autoscaling for RDS Aurora (MySQL) read replicas"
  type        = bool
  default     = true
}

variable "replica_scale_max" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 5
}

variable "replica_scale_min" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 4
}

variable "replica_scale_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "replica_scale_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4.large's default max_connections"
  type        = number
  default     = 700
}

variable "replica_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "replica_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are RDSReaderAverageCPUUtilization and RDSReaderAverageDatabaseConnections"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "enabled_screts_manager" {
  description = "Whether to enable autoscaling for RDS Aurora (MySQL) read replicas"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  description = "Private subnet ids in which RDS & lambda function created"
  type        = list(string)
  default     = null
}
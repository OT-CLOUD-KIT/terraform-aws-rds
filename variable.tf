variable "identifier" {
  description = "Unique identifier for the RDS instance/cluster"
  type        = string
}

variable "engine" {
  description = "The database engine to use"
  type        = string
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The amount of allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "username" {
  description = "Master username for the database"
  type        = string
}

variable "password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "parameter_family" {
  description = "Parameter group family (e.g., mysql8.0)"
  type        = string
}

variable "db_parameters" {
  description = "List of DB parameters for parameter group"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot before deletion"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately or during the next maintenance window"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance"
  type        = string
  default     = "Sun:23:45-Mon:00:15"
}

variable "backup_window" {
  description = "Daily time range for backups"
  type        = string
  default     = "00:00-01:00"
}

variable "monitoring_interval" {
  description = "Monitoring interval in seconds (0 to disable)"
  type        = number
  default     = 0
}

variable "enhanced_monitoring_role_enabled" {
  description = "Enable IAM role for enhanced monitoring"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable performance insights"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "KMS key for performance insights"
  type        = string
  default     = ""
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for storage encryption"
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "is_cluster" {
  description = "Whether to create Aurora cluster instead of standalone DB"
  type        = bool
  default     = false
}

variable "cluster_instance_count" {
  description = "Number of instances in Aurora cluster"
  type        = number
  default     = 2
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM authentication on RDS"
  type        = bool
  default     = false
}


variable "rds_security_group_id" {
  description = "SG ID used for RDS and Proxy"
  type        = string
}

# Proxy-specific variables
variable "enable_rds_proxy" {
  description = "Enable RDS Proxy"
  type        = bool
  default     = false
}

variable "rds_proxy_name" {
  description = "Name for RDS Proxy"
  type        = string
  default     = ""
}

variable "rds_proxy_secrets_arn" {
  description = "Secrets Manager ARN for RDS Proxy credentials"
  type        = string
  default     = ""
}


variable "env" {
  type = string
  default = "dev"
  
}

variable "owner" {
  type = string
  default = "opstree"
}

variable "app" {
  type = string
  default = "otcloud-kit"
  
}
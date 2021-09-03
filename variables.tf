variable "kubernetes_nickname" {
  type = string
  default = "prd"
}


variable "environment" {
  default = "prod"
  
}

variable "secret_manager_name" {
  description = "This name will be used as prefix for all the created resources"
  default = "rds-db-secret-manager"
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

variable "final_snapshot_identifier" {
  default = "aurora-mysql"
}

variable "restore_rds_from_snapshot" {
  description = "If value is true, it is required to provide snapshot arn to TF_VAR_snapshot_identifier otherwise, leave it blank"
  default = false
}

variable "snapshot_identifier" {
  description = "Required, when TF_VAR_restore_rds_from_snapshot is set to true"
  default = null
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = [
      {
      name         = "character_set_client"
      value        = "utf8"
      apply_method = "pending-reboot"
    }
  ]
  description = "List of DB cluster parameters to apply"
}

variable "instance_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = [
      {
      name         = "tx_isolation"
      value        = "READ-COMMITTED"
      apply_method = "pending-reboot"
    }
  ]
  description = "List of DB instance parameters to apply"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery"
  default     = ["audit", "general", "slowquery", "error"]
}

variable "enhanced_monitoring_role_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring"
  default     = false
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
  type        = bool
  default     = true
}
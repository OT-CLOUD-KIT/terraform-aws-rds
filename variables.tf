/*-------------------------------------------------------*/
variable "cluster_identifier" {
  default = ""
} 
variable "database_name" {
  default = ""
}
variable "master_username" {
  default = ""
}
variable "master_password" {
  default = ""
}
variable "backup_retention_period" {
  default = ""
}
variable "preferred_backup_window" {
  default = ""
}
variable "preferred_maintenance_window" {
  default = ""
}
variable "engine" {
  default = ""
}
variable "engine_version" {
  default = ""
}
variable "skip_final_snapshot" {
  default = ""
}
variable "availability_zones" {
  type = list(string)
}
variable "environment_name" {
  default = ""
}
variable "vpc_name" {
  default = ""
}
variable "vpc_security_group_ids" {
  type = list(string) 
}
// variable "snapshot_identifier" {
//   default = ""
// }
/*-------------------------------------------------------*/
variable "count_rds" {
  default = ""
}
variable "subnet_ids" {
  type = list(string)
} 
/*-------------------------------------------------------*/
variable "instance_type" {
  default = ""
}
variable "publicly_accessible" {
  default = ""
}
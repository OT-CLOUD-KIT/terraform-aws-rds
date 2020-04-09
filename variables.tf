/*-------------------------------------------------------*/
variable "cluster_identifier" {
  type = string
}
variable "database_name" {
  type = string
}
variable "master_username" {
  type = string
}
variable "master_password" {
  type = string
}
variable "backup_retention_period" {
  type = number
  default = 1
}
variable "preferred_backup_window" {
  type = string
}
variable "preferred_maintenance_window" {
  type = string
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = number
}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
variable "snapshot_identifier" {
  type = string
  default = ""
}
variable "skip_final_snapshot" {
  type = bool
  default = true
}
variable "environment_name" {
  default = ""
}
variable "vpc_name" {
  default = ""
}
/*-------------------------------------------------------*/
variable "subnet_ids" {
  type = list(string)
}
/*-------------------------------------------------------*/
variable "count" {
  type = number
}
variable "instance_class" {
  type = string
}
variable "publicly_accessible" {
  type = bool
}

/*-------------------------------------------------------*/
variable "allocated_storage" {
  type = number
}
variable "storage_type" {
  type = string
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = number
}
variable "instance_class" {
  type = string
}
variable "name" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "skip_final_snapshot" {
  type = bool
}


/*-------------------------------------------------------*/
variable "subnet_ids" {
  type = list(string)
}


locals {
  rds_master_user_credentials = {
    username = "opstree${random_string.root_username_suffix.result}"
    password = "${random_string.root_password.result}"
  }
}

resource "random_string" "root_username_suffix" {
  length  = 7
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_string" "root_password" {
  length  = 32
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_string" "schema_suffix" {
  length  = 8
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_string" "nonroot_username_suffix" {
  length  = 5
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_string" "nonroot_password" {
  length  = 32
  upper   = true
  lower   = true
  number  = true
  special = false
}

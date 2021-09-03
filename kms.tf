module "rds_kms_key" {
  source = "./kms"
  alias_name                  = "${var.environment}-rds-kms-key"
  environment                 = var.environment
  description                 = "Key to encrypt and decrypt secret parameters"
  deletion_window_in_days     = 7
}
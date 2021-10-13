resource "aws_kms_key" "key" {
  description             = "Key to encrypt and decrypt secret parameters"
  key_usage               = "ENCRYPT_DECRYPT"
  policy                  = var.kms_policy
  deletion_window_in_days = var.deletion_window_in_days
  is_enabled              = true
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = var.alias_name
  }) 
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.key.id
}

locals {
  vpc_id             = var.vpc_id
  private_subnet_ids = [
    "subnet-0894e943077b7a6e5",  # Replace with your subnet IDs
    "subnet-02eeeb8f96fa37b79",
    "subnet-05fc57d9a2188d2b8",
  ]
}

resource "aws_db_subnet_group" "BuildRDSSubnetGroup" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = local.private_subnet_ids  # Ensure it's a list of subnet IDs
  tags = merge(var.tags, {
    Name = "RDS-Subnet-Group"
  })
}
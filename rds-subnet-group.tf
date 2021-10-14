
locals {
  vpc_id         = "${var.vpc_id}"
  private_subnet_ids = ["${var.private_subnet_ids}"]
}

resource "aws_db_subnet_group" "BuildRDSSubnetGroup" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = local.private_subnet_ids
  tags = merge(var.tags, {
    Name = "RDS-Subnet-Group"
  })
}

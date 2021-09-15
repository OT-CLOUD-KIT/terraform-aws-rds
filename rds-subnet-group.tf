
locals {
  vpc_id         = "vpc-02e53b90ea4d03854"
  vpc_cidr_block = "192.168.0.0/16"
  region         = "us-west-2"
  private_subnet_ids = [
    "subnet-04ddd92afb4f1f503",
    "subnet-070a47702c42b961d",
    "subnet-09fe55c38a76750e0"
  ]
  public_subnet_ids = [
    "subnet-0fc995f4748b9b401",
    "subnet-04052d035bad58bd3",
    "subnet-05d4b6d697f46e221"
  ]
}

resource "aws_db_subnet_group" "BuildRDSSubnetGroup" {
  name       = "rds-subnet-group-${var.kubernetes_nickname}"
  subnet_ids = local.private_subnet_ids
  tags = merge(var.tags, {
    Name = "RDS-Subnet-Group"
  })
}


# resource "aws_db_subnet_group" "replicaRDSSubnetGroup" {
#   provider                  = aws.secondary
#   name       = "rds-subnet-group-${var.kubernetes_nickname}"
#   subnet_ids = ["subnet-0f8895fabfc8a4296", "subnet-0781625664e9de11f"]
#   tags = merge(var.tags, {
#     Name = "RDS-Subnet-Group"
#   })
# }

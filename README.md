# RDS_cluster

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

- This terraform module will create a complete RDS cluster setup.
- This project is a part of opstree's ot-aws initiative for terraform modules.

## Usage

```sh
$   cat main.tf
/*-------------------------------------------------------*/
module "rds_cluster" {
  source                       = "../rds"
  cluster_identifier           = "devcluster"
  database_name                = "opstree"
  master_username              = "opstree"
  master_password              = "opstree"
  backup_retention_period      = 14
  preferred_backup_window      = "14:00-15:00"
  preferred_maintenance_window = "sat:15:00-sat:16:00"
  engine                       = "aurora-mysql"
  engine_version               = "5.7.12"
  vpc_security_group_ids       = [aws_security_group.frontend_sg.id]
  vpc_name                     = "opstree"
  environment_name             = "opstree-dev"
  subnet_ids                   = ["subnet-4c093572","subnet-00c33421"]
  instance_type                = "db.t2.small"
  availability_zones           = ["us-east-1e", "us-east-1d"]
  skip_final_snapshot          = true
  #snapshot_identifier         = var.snapshot_identifier
  publicly_accessible          = false
  count_rds                    = 1
}
/*-------------------------------------------------------*/
resource "aws_security_group" "frontend_sg" {
  name = "Frontend Security Group"
  vpc_id      = "vpc-fc5cc595"

  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
  }
}
/*-------------------------------------------------------*/
/*-------------------------------------------------------*/
```

```sh
$   cat output.tf
/*-------------------------------------------------------*/

/*-------------------------------------------------------*/
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_identifier | The cluster identifier. If omitted, Terraform will assign a random, unique identifier. | `string` | `null` | no |
| database_name | Name for an automatically created database on cluster creation. | `string` | `null` | no |
| master_username | Username for the master DB user | `string` | `null` | yes |
| master_password | Password for the master DB user. | `string` | `null` | yes |
| backup_retention_period | The days to retain backups for. | `number` | `1` | no |
| preferred_backup_window | The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per region. | `string` | `null` | yes |
| preferred_maintenance_window | The weekly time range during which system maintenance can occur, in (UTC). | `string` | `null` | yes |
| engine | The database engine | `string` | `null` | yes |
| engine_version | The database engine version | `number` | `null` | yes |
| vpc_security_group_ids | List of VPC security groups to associate. | `list(string)` | `null` | yes |
| availability_zones | A list of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. | `list(string)` | `null` | no |
| snapshot_identifier | Specifies whether or not to create this cluster from a snapshot | `string` | `null` | no |
| skip_final_snapshot  | Determines whether a final DB snapshot is created before the DB cluster is deleted. |`bool` | `true` | no |
| environment_name | The name of the environment. | `string` | `null` | yes |
| vpc_name | The name of the VPC | `string` | `null` | no
| subnet_ids | The list of subnet ids | `list(string)` | `null` | yes |
| count | The number instances in the cluster | `number` | `null` | yes |
| instance_class | The RDS instance class | `string` | `null` | yes |
| publicly_accessible | Bool to control if instance is publicly accessible | `bool` | `false` | no |



## Outputs

| Name | Description |
|------|-------------|
| db_instance_endpoint | Endpoint of the DB instance |
| db_instance_port | Port of the DB instance |


## Related Projects

Check out these related projects.

- [network_skeleton](https://gitlab.com/ot-aws/terrafrom_v0.12.21/network_skeleton) - Terraform module for providing a general purpose Networking solution
- [security_group](https://gitlab.com/ot-aws/terrafrom_v0.12.21/security_group) - Terraform module for creating dynamic Security groups
- [eks](https://gitlab.com/ot-aws/terrafrom_v0.12.21/eks) - Terraform module for creating elastic kubernetes cluster.
- [HA_ec2_alb](https://gitlab.com/ot-aws/terrafrom_v0.12.21/ha_ec2_alb.git) - Terraform module for creating a Highly available setup of an EC2 instance with quick disater recovery.
- [HA_ec2](https://gitlab.com/ot-aws/terrafrom_v0.12.21/ha_ec2.git) - Terraform module for creating a Highly available setup of an EC2 instance with quick disater recovery.
- [rolling_deployment](https://gitlab.com/ot-aws/terrafrom_v0.12.21/rolling_deployment.git) - This terraform module will orchestrate rolling deployment.

### Contributors

[![Sudipt Sharma][sudipt_avatar]][sudipt_homepage]<br/>[Sudipt Sharma][sudipt_homepage] 

  [sudipt_homepage]: https://github.com/iamsudipt
  [sudipt_avatar]: https://img.cloudposse.com/150x150/https://github.com/iamsudipt.png
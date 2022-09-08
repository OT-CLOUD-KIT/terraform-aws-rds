## RDS

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

- This terraform module will create a complete RDS setup.
- This projecct is a part of opstree's ot-aws initiative for terraform modules.

## Usage

```sh
$   cat main.tf
/*-------------------------------------------------------*/
module "rds" {
  source                 = "../"
  allocated_storage      = "20"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "opstree"
  username               = "otaws"
  password               = "foobarbaz"
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  skip_final_snapshot    = true
  subnet_ids             = ["subnet-jhgfbhsdd","subnet-wjwehvdkvhv"]
}
/*-------------------------------------------------------*/
```

```sh
$   cat output.tf
/*-------------------------------------------------------*/
output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}
output "db_instance_port" {
  value = module.rds.db_instance_port
}
/*-------------------------------------------------------*/
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allocated_storage | The amount of allocated storage. | `number` | `null` | yes |
| storage_type | One of `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD). The default is `io1` if iops is specified, `gp2` if not. | `string` | `null` | no |
| engine | The database engine | `string` | `null` | yes |
| engine_version | The database engine version | `number` | `null` | yes |
| instance_class | The RDS instance class | `string` | `null` | yes |
| name | The name of the RDS instance | `string` | `null` | yes |
| username | The master username for the database. | `string` | `null` | yes |
| password | The master password for the database. | `string` | `null` | yes |
| vpc_security_group_ids | List of VPC security groups to associate. | `list(string)` | `null` | yes |
| subnet_ids | The list of subnet ids | `list(string)` | `null` | yes |

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
  [sudipt_avatar]: https://img.cloudposse.com/75x75/https://github.com/iamsudipt.png

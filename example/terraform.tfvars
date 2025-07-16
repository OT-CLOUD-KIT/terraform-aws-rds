# -----------------------------------------
# Naming & Tagging
# -----------------------------------------
bu       = "bp"
program  = "ot"
team     = "devops"
app      = "ot"
env      = "d"
region   = "us-east-1"
resource = "rds-ec2"

# -----------------------------------------
# RDS Configuration
# -----------------------------------------
identifier                          = "dev-mysql"
engine                              = "mysql"
engine_version                      = "8.0.36"
instance_class                      = "db.t3.medium"
allocated_storage                   = 20
multi_az                            = false
db_name                             = "exampledb"
username                            = "admin"
password                            = "strongpassword123"
port                                = 3306
subnet_ids                          = ["subnet-0759f0a3ac70e88c7", "subnet-0d5d2a5274faf7485"]
skip_final_snapshot                 = true
apply_immediately                   = true
backup_retention_period             = 7
maintenance_window                  = "Mon:00:00-Mon:03:00"
backup_window                       = "03:00-06:00"
monitoring_interval                 = 0
enhanced_monitoring_role_enabled    = true
performance_insights_enabled        = false
performance_insights_kms_key_id     = ""
storage_encrypted                   = false
kms_key_id                          = ""
deletion_protection                 = false
is_cluster                          = false
cluster_instance_count              = 0
parameter_family                    = "mysql8.0"
iam_database_authentication_enabled = false

db_parameters = [
  {
    name  = "slow_query_log"
    value = "1"
  },
  {
    name  = "long_query_time"
    value = "2"
  }
]

# -----------------------------------------
# RDS Proxy
# -----------------------------------------
enable_rds_proxy      = false
rds_proxy_name        = "db-proxy"
rds_proxy_secrets_arn = ""

# -----------------------------------------
# Security Groups
# -----------------------------------------
# -----------------------------------------
# Security Groups
# -----------------------------------------
enable_public_rds_security_group_resource = true
enable_public_ec2_security_group_resource = true

existing_rds_sg_id = ""
existing_sg_id     = ""

rds_sg_name = "rds-sg"
ec2_sg_name = "ec2-sg"



vpc_id = "vpc-03ddd7fd3163cc23a"

# -----------------------------------------
# EC2 Configuration
# -----------------------------------------
create_ec2_instance  = true
count_ec2_instance   = 1
existing_instance_id = "i-09460f2f0f2b8a8b2"

ami_id        = "ami-020cba7c55df1f615"
instance_type = "t2.micro"
key_name      = "KEY"
subnet        = ["subnet-0b122c2762f8a9810"]
public_ip     = true

iam_instance_profile    = ""
disable_api_termination = false
enable_monitoring       = true
ebs_optimized           = true
user_data               = ""
private_ip              = null

volume_size                      = 8
volume_type                      = "gp3"
encrypted_volume                 = true
root_block_iops                  = 3000
root_block_delete_on_termination = true

metadata_http_tokens   = "required"
metadata_http_endpoint = "enabled"
metadata_tags          = "enabled"

enable_enclave = false
auto_recovery  = "default"



create_ebs_volume          = false
attach_existing_ebs_volume = false
secondary_ebs_volumes = [
  {
    device_name = "/dev/sdf"
    volume_size = 20
    encrypted   = true
    type        = "gp3"
    tags = {
      Purpose = "AppData"
    }
  }
]

secondary_existing_ebs_volumes = [
  {
    device_name = "/dev/sdg"
    volume_id   = "vol-0c181fc4efb8832d5"
  }
]


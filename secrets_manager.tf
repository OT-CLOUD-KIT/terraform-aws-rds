data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_rotation" {
  name = "${var.environment}-${var.secret_manager_name}-rotation_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${var.environment}-${var.secret_manager_name}-lambda"
  roles      = ["${aws_iam_role.lambda_rotation.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]
    resources = [ "*",]
  }
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
    ]
  }
  statement {
    actions = ["secretsmanager:GetRandomPassword"]
    resources = ["*",]
  }
}

resource "aws_iam_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  name   = "${var.environment}-${var.secret_manager_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy.json
}


resource "aws_iam_policy_attachment" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  name       = "${var.environment}-${var.secret_manager_name}"
  roles      = ["${aws_iam_role.lambda_rotation.name}"]
  policy_arn = aws_iam_policy.SecretsManagerRDSMySQLRotationSingleUserRolePolicy.arn
}

resource "aws_security_group" "lambda" {
    vpc_id = local.vpc_id
    name = "${var.environment}-${var.secret_manager_name}-Lambda-SecretManager"
    tags = {
        Name                        = "${var.environment}-${var.secret_manager_name}-Lambda-SecretManager"
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_lambda_function" "rotate-code-mysql" {
  depends_on = [aws_rds_cluster.EPRDSCluster, aws_rds_cluster_instance.EPRDSInstances]
  filename           = "${path.module}/${var.filename}.zip"
  function_name      = "${var.secret_manager_name}-${var.filename}"
  role               = aws_iam_role.lambda_rotation.arn
  handler            = "lambda_function.lambda_handler"
  source_code_hash   = filebase64sha256("${path.module}/${var.filename}.zip")
  runtime            = "python3.7"
  tags = {
    Name                        = "${var.environment}-${var.secret_manager_name}-Lambda-SecretManager"
  }
  vpc_config {
    subnet_ids         = local.private_subnet_ids
    security_group_ids = ["${aws_security_group.lambda.id}"]
  }
  timeout            = 30
  description        = "Conducts an AWS SecretsManager secret rotation for RDS MySQL using single user rotation scheme"
  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secret_manager_call_Lambda" {
    function_name = aws_lambda_function.rotate-code-mysql.function_name
    statement_id = "AllowExecutionSecretManager"
    action = "lambda:InvokeFunction"
    principal = "secretsmanager.amazonaws.com"
}

resource "aws_kms_key" "secret" {
  description         = "Key for secret ${var.secret_manager_name}"
  enable_key_rotation = true
  #policy              = "${data.aws_iam_policy_document.kms.json}"
  tags = {
        Name = var.secret_manager_name
    }
  policy = <<POLICY
{
  "Id": "key-consolepolicy-3",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_rotation.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:Update*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_rotation.arn}"
        ]
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "secret" {
  name          = "alias/${var.environment}-${var.secret_manager_name}"
  target_key_id = aws_kms_key.secret.key_id
}



resource "aws_secretsmanager_secret_rotation" "rds_secret_rotation" {
  depends_on = [aws_rds_cluster.EPRDSCluster, aws_rds_cluster_instance.EPRDSInstances]
  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = aws_lambda_function.rotate-code-mysql.arn

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}

resource "aws_secretsmanager_secret" "secret" {
  depends_on = [aws_rds_cluster.EPRDSCluster, aws_rds_cluster_instance.EPRDSInstances]
  description         = var.secret_description
  kms_key_id          = aws_kms_key.secret.key_id
  name                = "${var.environment}-${var.secret_manager_name}"
  tags = {
      Name = var.secret_manager_name
    }

}

resource "aws_secretsmanager_secret_version" "secret" {
  depends_on = [aws_rds_cluster.EPRDSCluster, aws_rds_cluster_instance.EPRDSInstances]
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = <<EOF
{
  "username": "${local.rds_master_user_credentials.username}",
  "password": "${local.rds_master_user_credentials.password}",
  "engine": "mysql",
  "host": "${aws_rds_cluster.EPRDSCluster.endpoint}",
  "port": "${local.db-port}"
}
EOF
}
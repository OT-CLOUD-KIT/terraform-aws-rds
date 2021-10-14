data "aws_partition" "current" {}
data "aws_region" "current" {}
# data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_rotation" {
  count = var.enabled_screts_manager == true ? 1 : 0
  name               = "${var.environment}-${var.secret_manager_name}-rotation_lambda"
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
  count = var.enabled_screts_manager == true ? 1 : 0
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
    resources = ["*", ]
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
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*", ]
  }
}

resource "aws_iam_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  count = var.enabled_screts_manager == true ? 1 : 0
  name   = "${var.environment}-${var.secret_manager_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy.json
}


resource "aws_iam_policy_attachment" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  count = var.enabled_screts_manager == true ? 1 : 0
  name       = "${var.environment}-${var.secret_manager_name}"
  roles      = ["${aws_iam_role.lambda_rotation.name}"]
  policy_arn = aws_iam_policy.SecretsManagerRDSMySQLRotationSingleUserRolePolicy.arn
}

resource "aws_security_group" "lambda" {
  count = var.enabled_screts_manager == true ? 1 : 0
  vpc_id = local.vpc_id
  name   = "${var.environment}-${var.secret_manager_name}-Lambda-SecretManager"
    tags = merge(var.tags, {
    Name = "${var.secret_manager_name}-lambda-sg"
  })
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lambda_function" "rotate-code-mysql" {
  count = var.enabled_screts_manager == true ? 1 : 0
  depends_on       = [aws_rds_cluster.rds_cluster, aws_rds_cluster_instance.rds_instances]
  filename         = "${path.module}/${var.filename}.zip"
  function_name    = "${var.secret_manager_name}-${var.filename}"
  role             = aws_iam_role.lambda_rotation.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/${var.filename}.zip")
  runtime          = "python3.7"
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.secret_manager_name}-Lambda-SecretManager"
  })
  vpc_config {
    subnet_ids         = local.private_subnet_ids
    security_group_ids = ["${aws_security_group.lambda.id}"]
  }
  timeout     = 30
  description = "Conducts an AWS SecretsManager secret rotation for RDS MySQL using single user rotation scheme"
  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secret_manager_call_Lambda" {
  count = var.enabled_screts_manager == true ? 1 : 0
  function_name = aws_lambda_function.rotate-code-mysql.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}


resource "aws_secretsmanager_secret_rotation" "rds_secret_rotation" {
  count = var.enabled_screts_manager == true ? 1 : 0
  depends_on          = [aws_rds_cluster.rds_cluster, aws_rds_cluster_instance.rds_instances]
  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = aws_lambda_function.rotate-code-mysql.arn

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}

resource "aws_secretsmanager_secret" "secret" {
  count = var.enabled_screts_manager == true ? 1 : 0
  depends_on  = [aws_rds_cluster.rds_cluster, aws_rds_cluster_instance.rds_instances]
  description = var.secret_description
  kms_key_id  = module.secrets_kms_key[0].key_arn
  name        = "${var.environment}-${var.secret_manager_name}"
  tags = merge(var.tags, {
    Name = var.secret_manager_name
  })
}

resource "aws_secretsmanager_secret_version" "secret" {
  count = var.enabled_screts_manager == true ? 1 : 0
  depends_on = [aws_rds_cluster.rds_cluster, aws_rds_cluster_instance.rds_instances]
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
  "host": "${aws_rds_cluster.rds_cluster.endpoint}",
  "port": "${var.port}"
}
EOF
}

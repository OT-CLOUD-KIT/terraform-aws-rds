data "aws_caller_identity" "current" {
}

# data "aws_iam_user" "terraform_svc" {
#   user_name = "terraform_svc"
# }

data "aws_iam_policy_document" "rds_cmk_key_policy" {
  statement {
    sid = "1"

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]
  }
}

module "rds_kms_key" {
  source = "./kms"
  count = 1
  #count = var.storage_encrypted == "true" ? 1 : 0
  alias_name                  = "${var.environment}-rds-kms-key"
  deletion_window_in_days     = 7
  kms_policy                  =  data.aws_iam_policy_document.rds_cmk_key_policy.json
  tags   = var.tags
}


module "secrets_kms_key" {
  source = "./kms"
  count = 1
  alias_name                  = "${var.environment}-secrets-kms-key-test"
  deletion_window_in_days     = 7
  tags   = var.tags
  kms_policy  = <<POLICY
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
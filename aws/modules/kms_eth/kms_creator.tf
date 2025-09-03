# ***************************************
# Module Data
# ***************************************
data "aws_caller_identity" "current" {}

# ***************************************
# KMS - Ethereum Keypair
# ***************************************
resource "aws_kms_key" "this" {
  count = var.for_key_creater_account ? 1 : 0

  description  = var.kms_eth_description
  multi_region = var.kms_eth_multi_region

  key_usage                = var.kms_eth_key_usage
  customer_master_key_spec = var.kms_eth_customer_master_key_spec

  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "default"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow cross-account use of key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.kms_user_account_id}:root"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.kms_eth_tags,
    {
      Name = var.kms_eth_description
    }
  )
}

# ***************************************
# KMS - Alias for Ethereum Keypair
# ***************************************
resource "aws_kms_alias" "this" {
  count = var.for_key_creater_account ? 1 : 0

  name          = var.kms_eth_alias_name
  target_key_id = aws_kms_key.this[0].key_id
}

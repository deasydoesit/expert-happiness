# ***************************************
# Module Data
# ***************************************
data "aws_caller_identity" "current" {}

# ***************************************
# KMS - Ethereum Keypair
# ***************************************
resource "aws_kms_key" "this" {
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
  name          = var.kms_eth_alias_name
  target_key_id = aws_kms_key.this.key_id
}

# ***************************************
# KMS - Grant for IRSA for Ethereum Signer Pod
# ***************************************
resource "aws_kms_grant" "kms_signing_grant" {
  name = "ethereum-signer-kms-signing-grant"

  key_id            = aws_kms_key.this.key_id
  grantee_principal = aws_iam_role.kms_role.arn
  operations        = ["DescribeKey", "GetPublicKey", "Sign", "Verify"]

  retiring_principal = data.aws_caller_identity.current.arn
}

# ***************************************
# IAM - IRSA for Ethereum Signer Pod
# ***************************************
data "aws_iam_policy_document" "kms_assume_role_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.eth_signer_service_account_namespace}:${var.eth_signer_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowKMSSigningOperations"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
      "kms:Verify"
    ]
    resources = [aws_kms_key.this.arn]
  }
}

resource "aws_iam_role" "kms_role" {
  name        = "ethereum-signer-role"
  description = "IAM Role used by ${var.eth_signer_service_account_name} service account in EKS cluster for KMS signing operations"

  assume_role_policy = data.aws_iam_policy_document.kms_assume_role_policy.json

  tags = {
    Name = "ethereum-signer-role"
  }
}

resource "aws_iam_policy" "kms_iam_policy" {
  name        = "ethereum-signer-policy"
  description = "IAM policy for KMS signing operations used by ${var.eth_signer_service_account_name} service account"

  policy = data.aws_iam_policy_document.kms_policy.json

  tags = {
    Name = "ethereum-signer-policy"
  }
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role       = aws_iam_role.kms_role.name
  policy_arn = aws_iam_policy.kms_iam_policy.arn
}

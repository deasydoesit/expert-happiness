# ***************************************
# IAM - IRSA for Ethereum Signer Pod
# ***************************************
data "aws_iam_policy_document" "kms_assume_role_policy" {
  count = var.for_key_user_account ? 1 : 0

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
  count = var.for_key_user_account ? 1 : 0

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
    resources = [var.kms_arn]
  }
}

resource "aws_iam_role" "kms_role" {
  count = var.for_key_user_account ? 1 : 0

  name        = "ethereum-signer-role"
  description = "IAM Role used by ${var.eth_signer_service_account_name} service account in EKS cluster for KMS signing operations"

  assume_role_policy = data.aws_iam_policy_document.kms_assume_role_policy[0].json

  tags = {
    Name = "ethereum-signer-role"
  }
}

resource "aws_iam_policy" "kms_iam_policy" {
  count = var.for_key_user_account ? 1 : 0

  name        = "ethereum-signer-policy"
  description = "IAM policy for KMS signing operations used by ${var.eth_signer_service_account_name} service account"

  policy = data.aws_iam_policy_document.kms_policy[0].json

  tags = {
    Name = "ethereum-signer-policy"
  }
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  count = var.for_key_user_account ? 1 : 0

  role       = aws_iam_role.kms_role[0].name
  policy_arn = aws_iam_policy.kms_iam_policy[0].arn
}
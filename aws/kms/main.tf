# ***************************************
# KMS (for Ethereum keypair)
# ***************************************
module "kms_eth" {
  source = "../modules/kms_eth"

  # Cross Account
  for_key_creater_account = var.for_key_creater_account
  kms_user_arn            = var.kms_user_arn

  # KMS config
  kms_eth_description              = var.kms_eth_description
  kms_eth_multi_region             = var.kms_eth_multi_region
  kms_eth_key_usage                = var.kms_eth_key_usage
  kms_eth_customer_master_key_spec = var.kms_eth_customer_master_key_spec
  kms_eth_alias_name               = var.kms_eth_alias_name

  # Tags
  kms_eth_tags = var.kms_eth_tags
}
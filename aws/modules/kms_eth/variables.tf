# ***************************************
# KMS
# ***************************************
variable "kms_eth_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "Ethereum key created by Terraform"
}

variable "kms_eth_key_usage" {
  description = "Specifies the intended use of the key"
  type        = string
  default     = "SIGN_VERIFY"
}

variable "kms_eth_customer_master_key_spec" {
  description = "Specifies the type of key material in the KMS key"
  type        = string
  default     = "ECC_SECG_P256K1"
}

variable "kms_eth_multi_region" {
  description = "Indicates whether the KMS key is a multi-Region key"
  type        = bool
  default     = false
}

variable "kms_eth_tags" {
  description = "A map of tags to assign to the KMS key"
  type        = map(string)
  default     = {}
}

variable "kms_eth_alias_name" {
  description = "The display name of the alias. Must start with 'alias/'"
  type        = string
  default     = "alias/ethereum-keypair"
}

# ***************************************
# IAM
# ***************************************
variable "eth_signer_service_account_namespace" {
  description = "K8s namespace for ethereum signer pod"
  type        = string
  default     = "secure"
}

variable "eth_signer_service_account_name" {
  description = "K8s namespace for ethereum signer pod"
  type        = string
  default     = "ethereum-signer"
}

variable "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  type        = string
  default     = ""
}

variable "for_key_creater_account" {
  description = "Is the module used in key creater account?"
  type        = bool
  default     = false
}

variable "for_key_user_account" {
  description = "Is the module used in key user account?"
  type        = bool
  default     = false
}

variable "kms_arn" {
  description = "ARN of KMS Key"
  type        = string
  default     = ""
}

variable "kms_user_account_id" {
  description = "AWS account ID for KMS user"
  type        = string
  default     = ""
}
output "key_id" {
  description = "KMS ID for the Ethereum keypair"
  value       = var.for_key_creater_account ? module.kms_eth.key_id : null
}
output "key_id" {
  description = "KMS ID for the Ethereum keypair"
  value       = var.for_key_creater_account ? aws_kms_key.this[0].key_id : null
}
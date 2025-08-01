output "key_id" {
  description = "KMS ID for the Ethereum keypair"
  value       = aws_kms_key.this.key_id
}
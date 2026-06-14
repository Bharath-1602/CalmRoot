output "key_arn" {
  description = "The ARN of the customer managed KMS key"
  value       = aws_kms_key.calmroot.arn
}

output "key_id" {
  description = "The Key ID of the KMS key"
  value       = aws_kms_key.calmroot.key_id
}

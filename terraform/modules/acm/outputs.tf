output "certificate_arn" {
  description = "The ARN of the validated ACM SSL Certificate"
  value       = aws_acm_certificate_validation.cert.certificate_arn
}

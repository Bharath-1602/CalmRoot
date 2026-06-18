output "certificate_arn" {
  value       = aws_acm_certificate.main.arn
  description = "The requested certificate ARN"
}

output "domain_validation_options" {
  value       = aws_acm_certificate.main.domain_validation_options
  description = "Domain validation options from the certificate request"
}

output "zone_id" {
  value       = aws_route53_zone.main.zone_id
  description = "Route 53 hosted zone ID"
}

output "zone_name" {
  value       = aws_route53_zone.main.name
  description = "Route 53 hosted zone name"
}

output "nameservers" {
  value       = aws_route53_zone.main.name_servers
  description = "The list of Route 53 zone name servers"
}

output "validated_certificate_arn" {
  value       = try(aws_acm_certificate_validation.main[0].certificate_arn, var.certificate_arn)
  description = "The ARN of the validated ACM certificate"
}

output "cloudfront_domain_name" {
  description = "The DNS domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "The Hosted Zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}

output "cloudfront_distribution_id" {
  description = "The Distribution ID of CloudFront"
  value       = aws_cloudfront_distribution.cdn.id
}

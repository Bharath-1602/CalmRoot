output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint URL"
}

output "ecr_repository_urls" {
  value       = module.ecr.repository_urls
  description = "Map of ECR repository names to URLs"
}

output "kms_key_arn" {
  value       = module.security.kms_key_arn
  description = "Master KMS encryption Key ARN"
}

output "secrets_manager_jwt_arn" {
  value       = module.secrets.jwt_secret_arn
  description = "Secrets Manager JWT Secret ARN"
}

output "secrets_manager_ses_arn" {
  value       = module.secrets.ses_secret_arn
  description = "Secrets Manager SES Secret ARN"
}

output "github_actions_role_arn" {
  value       = module.security.github_actions_role_arn
  description = "IAM Role ARN for GitHub Actions deployment integration"
}

# --- CloudFront & DNS outputs ---
output "cloudfront_domain_name" {
  value       = module.cloudfront.distribution_domain_name
  description = "CloudFront Distribution Domain Name"
}

output "cloudfront_hosted_zone_id" {
  value       = module.cloudfront.distribution_hosted_zone_id
  description = "CloudFront Distribution Hosted Zone ID"
}

output "route53_nameservers" {
  value       = module.route53.nameservers
  description = "Name servers associated with the new hosted zone"
}

output "action_required" {
  value = <<-EOT
    ⚠️  IMPORTANT — MANUAL ACTION REQUIRED:
    
    Route 53 hosted zone created for: ${var.domain_name}
    
    You MUST update your domain registrar with these nameservers:
    ${join("\n    ", module.route53.nameservers)}
    
    Steps:
    1. Log in to your domain registrar (Namecheap/GoDaddy/etc.)
    2. Find DNS settings for wellnest-project.online
    3. Replace existing nameservers with the 4 above
    4. Save changes (propagation: 5 minutes to 48 hours)
    5. Once propagated, ACM cert will auto-validate
    6. CloudFront will start serving your domain
    
    Check propagation: https://dnschecker.org
  EOT
  description = "Instructions for manual domain delegation setup"
}

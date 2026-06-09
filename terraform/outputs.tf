output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_alb_dns_name" {
  description = "The DNS entrypoint of the public Application Load Balancer"
  value       = module.alb.public_alb_dns_name
}

output "internal_alb_dns_name" {
  description = "The DNS name of the internal private Load Balancer"
  value       = module.alb.internal_alb_dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = module.ec2.bastion_public_ip
}

output "route53_nameservers" {
  description = "Route53 Hosted Zone Name Servers. Update your GoDaddy Domain Nameservers with these values."
  value       = module.route53.name_servers
}

output "cloudfront_domain_name" {
  description = "The CloudFront Distribution Domain Name"
  value       = var.enable_cloudfront ? module.cloudfront[0].cloudfront_domain_name : "CloudFront is disabled in this environment (Direct ALB Routing Active)"
}

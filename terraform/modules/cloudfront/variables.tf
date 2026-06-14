variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "domain_name" {
  description = "Base domain name for CNAMEs (e.g., calmroot-project.online)"
  type        = string
}

variable "public_alb_dns" {
  description = "DNS name of the public ALB to use as origin"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to use with CloudFront"
  type        = string
}

variable "waf_arn" {
  description = "ARN of the WAFv2 Web ACL to associate with CloudFront"
  type        = string
}

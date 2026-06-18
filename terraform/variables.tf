variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID"
  default     = "006805625766"
}

variable "aws_region" {
  type        = string
  description = "The AWS Region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "calmroot"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC"
  default     = "10.0.0.0/16"
}

variable "github_username" {
  type        = string
  description = "The GitHub username or org name"
  default     = "Bharath-1602"
}

variable "github_repo" {
  type        = string
  description = "The GitHub repository name"
  default     = "CalmRoot"
}

variable "alert_email" {
  type        = string
  description = "Email address for CloudWatch metric alert notifications"
  default     = "ops-notifications@calmroot.com"
}

# --- CloudFront & Domain configurations ---
variable "domain_name" {
  type        = string
  description = "The application domain name"
  default     = "wellnest-project.online"
}

variable "nlb_dns_name" {
  type        = string
  description = "The DNS name of the Network Load Balancer created by Envoy Gateway"
  default     = "placeholder.example.com"
}

variable "cloudfront_secret_header" {
  type        = string
  description = "A random/secret header value to prevent direct traffic bypassing CloudFront"
  default     = "calmroot-prod-secret-header-123456"
}

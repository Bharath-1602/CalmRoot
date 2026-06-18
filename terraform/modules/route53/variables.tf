variable "project_name" {
  type        = string
  description = "Project name"
}

variable "domain_name" {
  type        = string
  description = "The application domain name"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "The target CloudFront distribution domain name"
  default     = ""
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront fixed hosted zone ID"
  default     = "Z2FDTNDATAQYW2"
}

variable "domain_validation_options" {
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_value = string
    resource_record_type  = string
  }))
  description = "ACM cert domain validation options"
  default     = []
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate to validate"
  default     = ""
}

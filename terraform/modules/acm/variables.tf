variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
}

variable "zone_id" {
  description = "The Route53 Hosted Zone ID for validation record creation"
  type        = string
}

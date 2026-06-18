variable "domain_name" {
  type        = string
  description = "The domain name to request the certificate for"
}

variable "zone_id" {
  type        = string
  description = "The Route 53 zone ID for DNS validation"
}

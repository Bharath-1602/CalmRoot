# Route 53 Managed Hosted Zone, DNS Records, and ACM Validation

# 1. Create Hosted Zone
resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "CalmRoot production hosted zone"

  tags = {
    Name = "${var.project_name}-hosted-zone"
  }
}

# 2. Apex A Record → CloudFront Alias
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# 3. www CNAME Record → Apex
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.domain_name]
}

# 4. ACM Validation DNS Records
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in var.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

# 5. ACM Validation Waiter (Breaks loop by residing here)
resource "aws_acm_certificate_validation" "main" {
  count                   = var.certificate_arn != "" ? 1 : 0
  certificate_arn         = var.certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

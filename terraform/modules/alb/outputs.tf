output "public_alb_dns_name" {
  description = "The DNS name of the external public ALB"
  value       = aws_lb.public.dns_name
}

output "internal_alb_dns_name" {
  description = "The DNS name of the internal private ALB"
  value       = aws_lb.internal.dns_name
}

output "frontend_tg_arn" {
  description = "The ARN of the frontend Target Group"
  value       = aws_lb_target_group.frontend.arn
}

output "auth_tg_arn" {
  description = "The ARN of the auth service Target Group"
  value       = aws_lb_target_group.auth.arn
}

output "assessment_tg_arn" {
  description = "The ARN of the assessment service Target Group"
  value       = aws_lb_target_group.assessment.arn
}

output "therapist_tg_arn" {
  description = "The ARN of the therapist service Target Group"
  value       = aws_lb_target_group.therapist.arn
}

# ARN Suffixes for Monitoring
output "public_alb_arn_suffix" {
  description = "The ARN suffix of the public ALB"
  value       = aws_lb.public.arn_suffix
}

output "internal_alb_arn_suffix" {
  description = "The ARN suffix of the internal ALB"
  value       = aws_lb.internal.arn_suffix
}

output "auth_tg_arn_suffix" {
  description = "The ARN suffix of the internal ALB auth Target Group"
  value       = aws_lb_target_group.auth.arn_suffix
}

output "public_alb_zone_id" {
  description = "The zone ID of the public ALB"
  value       = aws_lb.public.zone_id
}


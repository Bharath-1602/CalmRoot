output "instance_profile_name" {
  description = "The name of the existing backend IAM instance profile"
  value       = "wellnest-backend-ec2-role"
}

output "role_name" {
  description = "The name of the existing backend IAM role"
  value       = "wellnest-backend-ec2-role"
}

output "role_arn" {
  description = "The ARN of the existing backend IAM role"
  value       = "arn:aws:iam::${var.aws_account_id}:role/wellnest-backend-ec2-role"
}

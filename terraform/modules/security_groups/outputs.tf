output "bastion_sg_id" {
  description = "The ID of the Bastion security group"
  value       = aws_security_group.bastion.id
}

output "public_alb_sg_id" {
  description = "The ID of the Public ALB security group"
  value       = aws_security_group.public_alb.id
}

output "web_sg_id" {
  description = "The ID of the Web Frontend security group"
  value       = aws_security_group.web.id
}

output "internal_alb_sg_id" {
  description = "The ID of the Internal ALB security group"
  value       = aws_security_group.internal_alb.id
}

output "app_sg_id" {
  description = "The ID of the Backend App security group"
  value       = aws_security_group.app.id
}

output "frontend_asg_name" {
  description = "Name of the Frontend Auto Scaling Group"
  value       = aws_autoscaling_group.frontend.name
}

output "backend_asg_name" {
  description = "Name of the Backend Auto Scaling Group"
  value       = aws_autoscaling_group.backend.name
}

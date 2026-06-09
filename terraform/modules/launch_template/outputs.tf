output "frontend_launch_template_id" {
  description = "The ID of the Frontend launch template"
  value       = aws_launch_template.frontend.id
}

output "backend_launch_template_id" {
  description = "The ID of the Backend launch template"
  value       = aws_launch_template.backend.id
}

output "frontend_launch_template_latest_version" {
  description = "The latest version of the Frontend launch template"
  value       = aws_launch_template.frontend.latest_version
}

output "backend_launch_template_latest_version" {
  description = "The latest version of the Backend launch template"
  value       = aws_launch_template.backend.latest_version
}

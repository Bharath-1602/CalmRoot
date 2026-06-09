output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "web_public_subnet_ids" {
  description = "Map of public web subnet IDs keyed by availability zone"
  value       = { for az, subnet in aws_subnet.web_public : az => subnet.id }
}

output "app_private_subnet_ids" {
  description = "Map of private app subnet IDs keyed by availability zone"
  value       = { for az, subnet in aws_subnet.app_private : az => subnet.id }
}

output "db_private_subnet_ids" {
  description = "Map of private db subnet IDs keyed by availability zone"
  value       = { for az, subnet in aws_subnet.db_private : az => subnet.id }
}

output "web_public_subnet_list" {
  description = "List of public web subnet IDs"
  value       = [for subnet in aws_subnet.web_public : subnet.id]
}

output "app_private_subnet_list" {
  description = "List of private app subnet IDs"
  value       = [for subnet in aws_subnet.app_private : subnet.id]
}

output "app_private_route_table_id" {
  description = "The ID of the private app route table"
  value       = aws_route_table.app_private.id
}


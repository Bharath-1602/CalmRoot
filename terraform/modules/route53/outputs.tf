output "zone_id" {
  description = "The Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The Name Servers of the Hosted Zone"
  value       = aws_route53_zone.main.name_servers
}

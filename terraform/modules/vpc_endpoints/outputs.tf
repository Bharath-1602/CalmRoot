output "vpc_endpoint_sg_id" {
  description = "Security Group ID of the VPC Endpoints"
  value       = aws_security_group.endpoints.id
}

output "s3_endpoint_id" {
  description = "The ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where VPC endpoints are created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for security group configuration"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnets for placement of interface VPC endpoints"
  type        = list(string)
}

variable "app_private_route_table_ids" {
  description = "List of private route table IDs for Gateway Endpoint associations"
  type        = list(string)
}

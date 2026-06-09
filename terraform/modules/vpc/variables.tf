variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "web_public_subnets" {
  description = "Map of public subnets to AZs"
  type        = map(string)
}

variable "app_private_subnets" {
  description = "Map of private app subnets to AZs"
  type        = map(string)
}

variable "db_private_subnets" {
  description = "Map of private db subnets to AZs"
  type        = map(string)
}

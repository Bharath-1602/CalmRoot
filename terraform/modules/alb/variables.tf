variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALBs and Target Groups will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the external load balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the internal load balancer"
  type        = list(string)
}

variable "public_alb_sg_id" {
  description = "Security Group ID for the external public load balancer"
  type        = string
}

variable "internal_alb_sg_id" {
  description = "Security Group ID for the internal private load balancer"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS listener"
  type        = string
}

variable "logs_bucket_name" {
  description = "The name of the S3 bucket to store access logs"
  type        = string
}

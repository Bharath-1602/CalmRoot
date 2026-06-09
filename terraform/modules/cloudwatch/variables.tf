variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS Customer Managed Key for log group encryption"
  type        = string
}

variable "raw_sns_topic_arn" {
  description = "ARN of the raw SNS alarms topic for alert actions"
  type        = string
}

variable "public_alb_arn_suffix" {
  description = "ARN Suffix of the public Load Balancer for CloudWatch metrics"
  type        = string
}

variable "internal_alb_arn_suffix" {
  description = "ARN Suffix of the internal Load Balancer for CloudWatch metrics"
  type        = string
}

variable "internal_alb_auth_tg_arn_suffix" {
  description = "ARN Suffix of the internal ALB auth Target Group for CloudWatch metrics"
  type        = string
}

variable "frontend_asg_name" {
  description = "Name of the Frontend Auto Scaling Group for CPU monitoring"
  type        = string
}

variable "backend_asg_name" {
  description = "Name of the Backend Auto Scaling Group for CPU monitoring"
  type        = string
}

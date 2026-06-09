variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "frontend_launch_template_id" {
  description = "Launch Template ID for Frontend ASG"
  type        = string
}

variable "frontend_launch_template_version" {
  description = "Launch Template version for Frontend ASG"
  type        = string
}

variable "backend_launch_template_id" {
  description = "Launch Template ID for Backend ASG"
  type        = string
}

variable "backend_launch_template_version" {
  description = "Launch Template version for Backend ASG"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for Frontend ASG"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Backend ASG"
  type        = list(string)
}

variable "frontend_tg_arn" {
  description = "Frontend ALB Target Group ARN"
  type        = string
}

variable "auth_tg_arn" {
  description = "Backend ALB Auth Target Group ARN"
  type        = string
}

variable "assessment_tg_arn" {
  description = "Backend ALB Assessment Target Group ARN"
  type        = string
}

variable "therapist_tg_arn" {
  description = "Backend ALB Therapist Target Group ARN"
  type        = string
}

variable "frontend_min_size" {
  description = "Minimum size for Frontend ASG"
  type        = number
}

variable "frontend_max_size" {
  description = "Maximum size for Frontend ASG"
  type        = number
}

variable "frontend_desired_capacity" {
  description = "Desired capacity for Frontend ASG"
  type        = number
}

variable "backend_min_size" {
  description = "Minimum size for Backend ASG"
  type        = number
}

variable "backend_max_size" {
  description = "Maximum size for Backend ASG"
  type        = number
}

variable "backend_desired_capacity" {
  description = "Desired capacity for Backend ASG"
  type        = number
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN for ASG event notifications"
  type        = string
}

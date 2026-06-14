variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for tagging and naming"
  type        = string
  default     = "CalmRoot"
}

variable "aws_account_id" {
  description = "AWS Account ID for resources policies"
  type        = string
  default     = "006805625766"
}

variable "key_name" {
  description = "EC2 Key Pair Name for SSH access"
  type        = string
  default     = "bha26"
}

variable "github_repo" {
  description = "GitHub Repository URL for cloning application codebase"
  type        = string
  default     = "https://github.com/Bharath-1602/CalmRoot-AWS.git"
}

variable "domain_name" {
  description = "Domain name registered for the platform"
  type        = string
  default     = "calmroot-project.online"
}

variable "ops_email" {
  description = "Operational Email address for Alarm notifications"
  type        = string
  default     = "bharath70135@gmail.com"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_public_subnets" {
  description = "Map of public subnets to AZs"
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
  }
}

variable "app_private_subnets" {
  description = "Map of app private subnets to AZs"
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.3.0/24"
    "us-east-1b" = "10.0.4.0/24"
  }
}



variable "bastion_instance_type" {
  description = "Instance type for the Bastion Host"
  type        = string
  default     = "t3.micro"
}

variable "frontend_instance_type" {
  description = "Instance type for the Frontend EC2 launch template"
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "Instance type for the Backend EC2 launch template"
  type        = string
  default     = "t3.small"
}

# Phase 2 AMI variables
variable "frontend_ami_id" {
  description = "Custom AMI ID for Frontend EC2"
  type        = string
  default     = "ami-02f07081de00d2b9a"
}

variable "backend_ami_id" {
  description = "Custom AMI ID for Backend EC2"
  type        = string
  default     = "ami-0083a76ac555094c5"
}

# Scaling configuration variables
variable "frontend_min_size" {
  description = "Minimum size for Frontend ASG"
  type        = number
  default     = 1
}

variable "frontend_max_size" {
  description = "Maximum size for Frontend ASG"
  type        = number
  default     = 1
}

variable "frontend_desired_capacity" {
  description = "Desired capacity for Frontend ASG"
  type        = number
  default     = 1
}

variable "backend_min_size" {
  description = "Minimum size for Backend ASG"
  type        = number
  default     = 1
}

variable "backend_max_size" {
  description = "Maximum size for Backend ASG"
  type        = number
  default     = 1
}

variable "backend_desired_capacity" {
  description = "Desired capacity for Backend ASG"
  type        = number
  default     = 1
}

variable "enable_cloudfront" {
  description = "Toggle to enable or disable CloudFront and ACM (useful to turn off in development to save cost)"
  type        = bool
  default     = true
}

# Existing AWS resources to be referenced (not managed)
variable "existing_dynamodb_tables" {
  description = "List of existing DynamoDB tables used by the application"
  type        = list(string)
  default = [
    "calmroot-users",
    "calmroot-assessment-templates",
    "calmroot-assessments",
    "calmroot-mood-logs",
    "calmroot-sessions",
    "calmroot-therapist-patients"
  ]
}

variable "existing_s3_buckets" {
  description = "List of existing S3 buckets used by the application"
  type        = list(string)
  default = [
    "calmroot-clinical-notes",
    "calmroot-daily-exports"
  ]
}

variable "existing_secrets" {
  description = "List of existing Secrets Manager secrets path"
  type        = list(string)
  default = [
    "calmroot/production/jwt-secret",
    "calmroot/production/app-config"
  ]
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Master Key ARN"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

# DynamoDB ARNs
variable "users_table_arn" {
  type        = string
  description = "Users table ARN"
}

variable "sessions_table_arn" {
  type        = string
  description = "Sessions table ARN"
}

variable "templates_table_arn" {
  type        = string
  description = "Assessment templates table ARN"
}

variable "assessments_table_arn" {
  type        = string
  description = "Assessments table ARN"
}

variable "mood_logs_table_arn" {
  type        = string
  description = "Mood logs table ARN"
}

variable "patients_table_arn" {
  type        = string
  description = "Therapist patients table ARN"
}

# S3 ARNs
variable "s3_clinical_notes_arn" {
  type        = string
  description = "Clinical notes S3 bucket ARN"
}

variable "s3_exports_arn" {
  type        = string
  description = "Exports S3 bucket ARN"
}

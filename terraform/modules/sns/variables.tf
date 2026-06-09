variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS Key for SNS encryption"
  type        = string
}

variable "ops_email" {
  description = "Operational Email address for notifications"
  type        = string
}

variable "alarm_notifier_lambda_arn" {
  description = "ARN of the Alarm Notifier Lambda function to trigger"
  type        = string
}

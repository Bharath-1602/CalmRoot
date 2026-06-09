variable "project_name" {
  description = "Project name for tagging and naming"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for resources"
  type        = string
}

variable "existing_dynamodb_tables" {
  description = "List of existing DynamoDB tables used by the application"
  type        = list(string)
}

variable "existing_s3_buckets" {
  description = "List of existing S3 buckets used by the application"
  type        = list(string)
}

variable "existing_secrets" {
  description = "List of existing Secrets Manager secrets"
  type        = list(string)
}

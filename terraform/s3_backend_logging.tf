# ==============================================================================
# S3 Buckets for Terraform State Backend and Unified Logging
# ==============================================================================

# 1. S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "tf_state" {
  bucket        = "calmroot-tf-state-${var.aws_account_id}"
  force_destroy = false

  tags = {
    Name      = "calmroot-tf-state-${var.aws_account_id}"
    Purpose   = "Terraform State Storage"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "tf_state_lock" {
  name         = "calmroot-tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "calmroot-tf-state-lock"
    Purpose   = "Terraform State Locking"
    ManagedBy = "Terraform"
  }
}

# 3. S3 Bucket for Unified Website & VPC Flow Logs
resource "aws_s3_bucket" "logs" {
  bucket        = "calmroot-logs-${var.aws_account_id}"
  force_destroy = true

  tags = {
    Name      = "calmroot-logs-${var.aws_account_id}"
    Purpose   = "Unified Logs Storage"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for ALB access logs and VPC Flow logs delivery
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ALB Access Logs Policy (us-east-1 ELB Account ID: 127311923021)
      {
        Sid       = "AllowALBAccessLogs"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"
        }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.logs.arn}/alb/*"
      },
      # VPC Flow Logs delivery policy
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.logs.arn}/vpc-flow-logs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "AWSLogDeliveryAclCheck"
        Effect    = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.logs.arn
      }
    ]
  })
}

# 4. VPC Flow Logs pointing to the logs S3 bucket
resource "aws_flow_log" "vpc" {
  log_destination      = "${aws_s3_bucket.logs.arn}/vpc-flow-logs"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id

  tags = {
    Name      = "calmroot-${terraform.workspace}-vpc-flow-log"
    ManagedBy = "Terraform"
  }
}

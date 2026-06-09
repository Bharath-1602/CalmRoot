resource "aws_kms_key" "wellnest" {
  description             = "WellNest encryption key for CloudWatch logs, SNS, and Lambdas"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "wellnest-key-policy"
    Statement = [
      # 1. Root account full access (delegates permission management to IAM policies)
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      # 2. Backend EC2 Role Access
      {
        Sid       = "Allow Backend EC2 Role Access"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:role/wellnest-backend-ec2-role"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource  = "*"
      },
      # 3. Lambda Roles Access
      {
        Sid       = "Allow Lambda Service Roles Access"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_account_id}:role/wellnest-${terraform.workspace}-daily-export-role",
            "arn:aws:iam::${var.aws_account_id}:role/wellnest-${terraform.workspace}-alarm-notifier-role"
          ]
        }
        Action    = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource  = "*"
      },
      # 4. CloudWatch Logs Service Principal Access
      {
        Sid       = "Allow CloudWatch Logs Service Principal Access"
        Effect    = "Allow"
        Principal = {
          Service = "logs.us-east-1.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource  = "*"
      },
      # 5. CloudWatch Alarms Service Principal Access (to publish to encrypted SNS topics)
      {
        Sid       = "Allow CloudWatch Alarms Service Principal Access"
        Effect    = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource  = "*"
      },
      # 6. Auto Scaling Service Principal Access
      {
        Sid       = "Allow ASG Service Principal Access"
        Effect    = "Allow"
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource  = "*"
      }
    ]
  })

  tags = {
    Name = "wellnest-${terraform.workspace}-kms-key"
  }
}

resource "aws_kms_alias" "wellnest" {
  name          = "alias/wellnest-${terraform.workspace}-key"
  target_key_id = aws_kms_key.wellnest.key_id
}

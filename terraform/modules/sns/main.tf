# SNS Raw Alarms Topic (Alarms publish raw JSON here -> triggers Lambda)
resource "aws_sns_topic" "raw_alarms" {
  name              = "calmroot-${terraform.workspace}-ops-alarms-raw"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name = "calmroot-${terraform.workspace}-ops-alarms-raw"
  }
}

# SNS Ops Alarms Topic (Lambda publishes formatted HTML here -> sends Email)
resource "aws_sns_topic" "ops_alarms" {
  name              = "calmroot-${terraform.workspace}-ops-alarms"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name = "calmroot-${terraform.workspace}-ops-alarms"
  }
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "alarm_notifier_lambda" {
  topic_arn = aws_sns_topic.raw_alarms.arn
  protocol  = "lambda"
  endpoint  = var.alarm_notifier_lambda_arn
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.ops_alarms.arn
  protocol  = "email"
  endpoint  = var.ops_email
}

data "aws_caller_identity" "current" {}

resource "aws_sns_topic_policy" "raw_alarms" {
  arn    = aws_sns_topic.raw_alarms.arn
  policy = data.aws_iam_policy_document.raw_alarms_policy.json
}

data "aws_iam_policy_document" "raw_alarms_policy" {
  statement {
    sid       = "AllowPublishToServices"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.raw_alarms.arn]

    principals {
      type        = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "autoscaling.amazonaws.com"
      ]
    }
  }

  statement {
    sid       = "AllowOwnerManage"
    effect    = "Allow"
    actions = [
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:DeleteTopic",
      "sns:AddPermission",
      "sns:GetTopicAttributes",
      "sns:Subscribe"
    ]
    resources = [aws_sns_topic.raw_alarms.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

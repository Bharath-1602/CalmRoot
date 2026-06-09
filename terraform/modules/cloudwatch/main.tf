# ==========================================
# 1. Encrypted CloudWatch Log Groups
# ==========================================
locals {
  log_groups = [
    "/wellnest/backend/auth-service",
    "/wellnest/backend/assessment-service",
    "/wellnest/backend/therapist-service",
    "/wellnest/backend/cloud-init",
    "/aws/lambda/wellnest-daily-export",
    "/aws/lambda/wellnest-${terraform.workspace}-alarm-notifier"
  ]
}

resource "aws_cloudwatch_log_group" "logs" {
  for_each          = toset(local.log_groups)
  name              = each.value
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = {
    Name = "wellnest-${terraform.workspace}-log-group"
  }
}

# ==========================================
# 2. CloudWatch Alarms (Directing to raw_alarms SNS)
# ==========================================

# Alarm 1: ALB 5XX Error Rate
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "wellnest-${terraform.workspace}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors the 5XX HTTP code counts on the external ALB."
  alarm_actions       = [var.raw_sns_topic_arn]

  dimensions = {
    LoadBalancer = var.public_alb_arn_suffix
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-alb-5xx-alarm"
  }
}

# Alarm 2: Backend CPU Utilization
resource "aws_cloudwatch_metric_alarm" "backend_cpu" {
  alarm_name          = "wellnest-${terraform.workspace}-backend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors average CPU utilization on the Backend ASG."
  alarm_actions       = [var.raw_sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = var.backend_asg_name
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-backend-cpu-alarm"
  }
}

# Alarm 3: Frontend CPU Utilization
resource "aws_cloudwatch_metric_alarm" "frontend_cpu" {
  alarm_name          = "wellnest-${terraform.workspace}-frontend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors average CPU utilization on the Frontend ASG."
  alarm_actions       = [var.raw_sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = var.frontend_asg_name
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-frontend-cpu-alarm"
  }
}

# Alarm 4: Daily Export Lambda Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "wellnest-${terraform.workspace}-lambda-export-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "This metric monitors execution errors on the daily assessments/mood logs export Lambda."
  alarm_actions       = [var.raw_sns_topic_arn]

  dimensions = {
    FunctionName = "wellnest-daily-export"
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-lambda-errors-alarm"
  }
}

# Alarm 5: Unhealthy Hosts on Internal ALB Target Groups
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "wellnest-${terraform.workspace}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This metric monitors unhealthy host counts on the internal ALB auth target group."
  alarm_actions       = [var.raw_sns_topic_arn]

  dimensions = {
    TargetGroup  = var.internal_alb_auth_tg_arn_suffix
    LoadBalancer = var.internal_alb_arn_suffix
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-unhealthy-hosts-alarm"
  }
}

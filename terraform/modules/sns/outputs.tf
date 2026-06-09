output "raw_sns_topic_arn" {
  description = "The ARN of the raw SNS alarms topic"
  value       = aws_sns_topic.raw_alarms.arn
}

output "formatted_sns_topic_arn" {
  description = "The ARN of the formatted SNS ops alarms topic"
  value       = aws_sns_topic.ops_alarms.arn
}

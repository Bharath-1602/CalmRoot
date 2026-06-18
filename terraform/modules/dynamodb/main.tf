# Read existing DynamoDB tables (Do not create)

data "aws_dynamodb_table" "users" {
  name = "calmroot-users"
}

data "aws_dynamodb_table" "sessions" {
  name = "calmroot-sessions"
}

data "aws_dynamodb_table" "assessment_templates" {
  name = "calmroot-assessment-templates"
}

data "aws_dynamodb_table" "assessments" {
  name = "calmroot-assessments"
}

data "aws_dynamodb_table" "mood_logs" {
  name = "calmroot-mood-logs"
}

data "aws_dynamodb_table" "therapist_patients" {
  name = "calmroot-therapist-patients"
}

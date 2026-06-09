variable "project_name" {
  description = "Project name for tagging and naming"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "frontend_instance_type" {
  description = "Instance type for the Frontend EC2 launch template"
  type        = string
}

variable "backend_instance_type" {
  description = "Instance type for the Backend EC2 launch template"
  type        = string
}

variable "frontend_ami_id" {
  description = "Custom AMI ID for Frontend EC2"
  type        = string
}

variable "backend_ami_id" {
  description = "Custom AMI ID for Backend EC2"
  type        = string
}

variable "web_sg_id" {
  description = "Security Group ID for Frontend EC2"
  type        = string
}

variable "app_sg_id" {
  description = "Security Group ID for Backend EC2"
  type        = string
}

variable "backend_instance_profile_name" {
  description = "IAM Instance Profile name for Backend EC2"
  type        = string
  default     = "wellnest-backend-ec2-role"
}

variable "internal_alb_dns_name" {
  description = "DNS name of the internal private ALB"
  type        = string
}

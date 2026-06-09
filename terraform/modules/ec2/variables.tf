variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for the Bastion Host"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Subnet ID for Bastion Host (must be a public subnet)"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security Group ID for Bastion"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

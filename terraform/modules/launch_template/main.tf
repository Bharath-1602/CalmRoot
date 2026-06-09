resource "aws_launch_template" "frontend" {
  name_prefix   = "wellnest-${terraform.workspace}-frontend-"
  image_id      = var.frontend_ami_id
  instance_type = var.frontend_instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.web_sg_id]
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(templatefile("${path.module}/templates/frontend_user_data.sh", {
    internal_alb_dns = var.internal_alb_dns_name
  }))

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wellnest-${terraform.workspace}-frontend-asg-node"
    }
  }
}

resource "aws_launch_template" "backend" {
  name_prefix   = "wellnest-${terraform.workspace}-backend-"
  image_id      = var.backend_ami_id
  instance_type = var.backend_instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = var.backend_instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/templates/backend_user_data.sh", {}))

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wellnest-${terraform.workspace}-backend-asg-node"
    }
  }
}

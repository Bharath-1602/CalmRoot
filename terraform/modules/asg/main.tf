resource "aws_autoscaling_group" "frontend" {
  name                      = "calmroot-${terraform.workspace}-frontend-asg"
  vpc_zone_identifier       = var.public_subnet_ids
  min_size                  = var.frontend_min_size
  max_size                  = var.frontend_max_size
  desired_capacity          = var.frontend_desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.frontend_tg_arn]

  launch_template {
    id      = var.frontend_launch_template_id
    version = var.frontend_launch_template_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "calmroot-${terraform.workspace}-frontend-asg-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend" {
  name                      = "calmroot-${terraform.workspace}-backend-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  min_size                  = var.backend_min_size
  max_size                  = var.backend_max_size
  desired_capacity          = var.backend_desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.auth_tg_arn, var.assessment_tg_arn, var.therapist_tg_arn]

  launch_template {
    id      = var.backend_launch_template_id
    version = var.backend_launch_template_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "calmroot-${terraform.workspace}-backend-asg-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Backend Auto Scaling Target Tracking CPU Policy (Target: 50% CPU)
resource "aws_autoscaling_policy" "backend_cpu" {
  name                   = "calmroot-${terraform.workspace}-backend-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_autoscaling_notification" "asg_notifications" {
  group_names = [
    aws_autoscaling_group.frontend.name,
    aws_autoscaling_group.backend.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = var.sns_topic_arn
}

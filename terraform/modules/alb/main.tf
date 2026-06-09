# ==========================================
# External Public Load Balancer & Target Group
# ==========================================

resource "aws_lb" "public" {
  name               = "wellnest-${terraform.workspace}-pb-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg_id]
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = var.logs_bucket_name
    prefix  = "alb"
    enabled = true
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-pb-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "wellnest-${terraform.workspace}-fr-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-frontend-tg"
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ==========================================
# Internal Private Load Balancer & Target Groups
# ==========================================

resource "aws_lb" "internal" {
  name               = "wellnest-${terraform.workspace}-it-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.private_subnet_ids

  access_logs {
    bucket  = var.logs_bucket_name
    prefix  = "alb"
    enabled = true
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-it-alb"
  }
}

# Auth Target Group (Port 3001)
resource "aws_lb_target_group" "auth" {
  name        = "wellnest-${terraform.workspace}-au-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "3001"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-auth-tg"
  }
}

# Assessment Target Group (Port 3002)
resource "aws_lb_target_group" "assessment" {
  name        = "wellnest-${terraform.workspace}-as-tg"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "3002"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-assessment-tg"
  }
}

# Therapist Target Group (Port 3003)
resource "aws_lb_target_group" "therapist" {
  name        = "wellnest-${terraform.workspace}-th-tg"
  port        = 3003
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "3003"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "wellnest-${terraform.workspace}-therapist-tg"
  }
}

# Internal listener - returns a 404 by default
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found - WellNest Internal Route"
      status_code  = "404"
    }
  }
}

# Listener Rules for path-based routing
resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.internal_http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/api/auth/*"]
    }
  }
}

resource "aws_lb_listener_rule" "assessment" {
  listener_arn = aws_lb_listener.internal_http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.assessment.arn
  }

  condition {
    path_pattern {
      values = ["/api/assessment/*"]
    }
  }
}

resource "aws_lb_listener_rule" "therapist" {
  listener_arn = aws_lb_listener.internal_http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.therapist.arn
  }

  condition {
    path_pattern {
      values = ["/api/therapist/*"]
    }
  }
}

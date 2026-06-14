# 1. Bastion Security Group
resource "aws_security_group" "bastion" {
  name        = "calmroot-${terraform.workspace}-bastion-sg"
  description = "Security Group for Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-bastion-sg"
  }
}

# 2. Public ALB Security Group
resource "aws_security_group" "public_alb" {
  name        = "calmroot-${terraform.workspace}-public-alb-sg"
  description = "Security Group for External Public Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-public-alb-sg"
  }
}

# 3. Web Security Group (Frontend EC2)
resource "aws_security_group" "web" {
  name        = "calmroot-${terraform.workspace}-web-sg"
  description = "Security Group for Web Frontend EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from Public ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }

  ingress {
    description     = "Allow SSH from Bastion Host only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-web-sg"
  }
}

# 4. Internal ALB Security Group
resource "aws_security_group" "internal_alb" {
  name        = "calmroot-${terraform.workspace}-internal-alb-sg"
  description = "Security Group for Private Internal Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from Web Frontend EC2"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-internal-alb-sg"
  }
}

# 5. App Security Group (Backend EC2)
resource "aws_security_group" "app" {
  name        = "calmroot-${terraform.workspace}-app-sg"
  description = "Security Group for Backend App EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Auth service traffic from Internal ALB"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    description     = "Allow Assessment service traffic from Internal ALB"
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    description     = "Allow Therapist service traffic from Internal ALB"
    from_port       = 3003
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    description     = "Allow SSH from Bastion Host only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-app-sg"
  }
}

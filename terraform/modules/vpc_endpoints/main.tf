# ==========================================
# Security Group for Interface VPC Endpoints
# ==========================================
resource "aws_security_group" "endpoints" {
  name        = "calmroot-${terraform.workspace}-vpc-endpoint-sg"
  description = "Security Group for Interface VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from inside the VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-vpc-endpoint-sg"
  }
}

# ==========================================
# Gateway Endpoints (Free)
# ==========================================

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.app_private_route_table_ids

  tags = {
    Name = "calmroot-${terraform.workspace}-vpce-s3"
  }
}

# DynamoDB Gateway Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.app_private_route_table_ids

  tags = {
    Name = "calmroot-${terraform.workspace}-vpce-ddb"
  }
}

# ==========================================
# Interface Endpoints (PrivateLink)
# ==========================================

# Secrets Manager Interface Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "calmroot-${terraform.workspace}-vpce-secrets"
  }
}

# KMS Interface Endpoint
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "calmroot-${terraform.workspace}-vpce-kms"
  }
}

# CloudWatch Logs (logs) Interface Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "calmroot-${terraform.workspace}-vpce-logs"
  }
}

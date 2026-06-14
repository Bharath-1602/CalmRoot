resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "calmroot-${terraform.workspace}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "calmroot-${terraform.workspace}-igw"
  }
}

# Public Web Subnets
resource "aws_subnet" "web_public" {
  for_each                = var.web_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "calmroot-${terraform.workspace}-web-public-${substr(each.key, -2, 2)}"
  }
}

# Private App Subnets
resource "aws_subnet" "app_private" {
  for_each          = var.app_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "calmroot-${terraform.workspace}-app-private-${substr(each.key, -2, 2)}"
  }
}

# Private DB Subnets
resource "aws_subnet" "db_private" {
  for_each          = var.db_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "calmroot-${terraform.workspace}-db-private-${substr(each.key, -2, 2)}"
  }
}

# NAT Gateway Elastic IP (EIP)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "calmroot-${terraform.workspace}-nat-eip"
  }
}

# NAT Gateway (placed in public web subnet 1a for Phase 1 cost efficiency)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  # We select the first public subnet (us-east-1a)
  subnet_id = aws_subnet.web_public["us-east-1a"].id

  tags = {
    Name = "calmroot-${terraform.workspace}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-public-rt"
  }
}

# App Private Route Table (Routes external traffic through NAT Gateway)
resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "calmroot-${terraform.workspace}-app-private-rt"
  }
}

# DB Private Route Table (Isolated from internet)
resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "calmroot-${terraform.workspace}-db-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "web_public" {
  for_each       = aws_subnet.web_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app_private" {
  for_each       = aws_subnet.app_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "db_private" {
  for_each       = aws_subnet.db_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db_private.id
}

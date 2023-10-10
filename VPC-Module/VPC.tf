# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-Public_Subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-Private_Subnet_${count.index + 1}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-rtb-public"
  }
}

resource "aws_route_table_association" "subnet-public_route" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.rtb-public.id
}

# Create Elastic IPs
resource "aws_eip" "nat_eip" {
  count  = var.az_count
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-eip-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat-public" {
  count         = var.az_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.project_name}-nat-public${count.index + 1}-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}


# Define route tables and associations
resource "aws_route_table" "private_rtb" {
  count  = var.az_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-public[count.index].id
  }

  tags = {
    Name = "${var.project_name}-nat-public${count.index + 1}-${element(data.aws_availability_zones.available.names, count.index)}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags, route]
  }
}

resource "aws_route_table_association" "private_subnet_route" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}



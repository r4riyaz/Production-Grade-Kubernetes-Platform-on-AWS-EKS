provider "aws" {
  region = "ap-south-1"
}

# -------------------------------------------------
# VPC
# -------------------------------------------------

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-eks-vpc"
  }
}

# -------------------------------------------------
# Internet Gateway
# -------------------------------------------------

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.environment}-eks-igw"
  }
}

# -------------------------------------------------
# Availability Zones
# -------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# -------------------------------------------------
# Public Subnets
# -------------------------------------------------

resource "aws_subnet" "eks_public_subnet" {
  count = var.az_count

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-eks-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------------------------------
# Private Subnets
# -------------------------------------------------

resource "aws_subnet" "eks_private_subnet" {
  count = var.az_count

  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-eks-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------------------------------
# Elastic IPs (For NAT)
# -------------------------------------------------

resource "aws_eip" "eks_nat_eip" {
  count  = var.az_count
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eks-nat-eip-${count.index + 1}"
  }
}

# -------------------------------------------------
# NAT Gateways
# -------------------------------------------------

resource "aws_nat_gateway" "eks_nat" {
  count = var.az_count

  allocation_id = aws_eip.eks_nat_eip[count.index].id
  subnet_id     = aws_subnet.eks_public_subnet[count.index].id

  tags = {
    Name = "${var.environment}-eks-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.eks_igw]
}

# -------------------------------------------------
# Public Route Table
# -------------------------------------------------

resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.environment}-eks-public-rt"
  }
}

resource "aws_route_table_association" "eks_public_rta" {
  count = var.az_count

  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_public_rt.id
}

# -------------------------------------------------
# Private Route Tables
# -------------------------------------------------

resource "aws_route_table" "eks_private_rt" {
  count  = var.az_count
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat[count.index].id
  }

  tags = {
    Name = "${var.environment}-eks-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "eks_private_rta" {
  count = var.az_count

  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_private_rt[count.index].id
}

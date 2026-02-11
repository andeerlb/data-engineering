# vpc
resource "aws_vpc" "redshift_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "redshift-vpc"
  }
}

# ig
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.redshift_vpc.id

  tags = {
    Name = "redshift-igw"
  }
}

# Subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.redshift_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "redshift-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.redshift_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "redshift-public-b"
  }
}

# route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.redshift_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
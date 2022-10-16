# Creating vpc

resource "aws_vpc" "slack_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "Slack-vpc"
  }
}

# Creating subnet for correspending vpc (public-subnet)
resource "aws_subnet" "slack-pub-1" {
  vpc_id                  = aws_vpc.slack_vpc.id
  cidr_block              = var.public_subnets_cidr[0]
  map_public_ip_on_launch = "true"
  availability_zone       = var.zone1
  tags = {
    Name = "slack-pub-1"
  }
}

resource "aws_subnet" "slack-pub-2" {
  vpc_id                  = aws_vpc.slack_vpc.id
  cidr_block              = var.public_subnets_cidr[1]
  map_public_ip_on_launch = "true"
  availability_zone       = var.zone2
  tags = {
    Name = "slack-pub-2"
  }
}


# Creating subnet for correspending vpc (private-subnet)

resource "aws_subnet" "slack-priv-1" {
  vpc_id                  = aws_vpc.slack_vpc.id
  cidr_block              = var.private_subnets_cidr[0]
  map_public_ip_on_launch = "false"
  availability_zone       = var.zone1
  tags = {
    Name = "slack-priv-1"
  }
}


resource "aws_subnet" "slack-priv-2" {
  vpc_id                  = aws_vpc.slack_vpc.id
  cidr_block              = var.private_subnets_cidr[1]
  map_public_ip_on_launch = "false"
  availability_zone       = var.zone2
  tags = {
    Name = "slack-priv-2"
  }
}


#Creating internet gateway for allowing public access
resource "aws_internet_gateway" "slack-IGW" {
  vpc_id = aws_vpc.slack_vpc.id
  tags = {
    Name = "slack-IGW"
  }
}

# Routing all access

resource "aws_route_table" "slack-pub-RT" {
  vpc_id = aws_vpc.slack_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.slack-IGW.id
  }

  tags = {
    Name = "slack-pub-RT"
  }
}

# Associating route table with public subnet 
resource "aws_route_table_association" "slack-pub-1-a" {
  subnet_id      = aws_subnet.slack-pub-1.id
  route_table_id = aws_route_table.slack-pub-RT.id
}

resource "aws_route_table_association" "slack-pub-2-a" {
  subnet_id      = aws_subnet.slack-pub-2.id
  route_table_id = aws_route_table.slack-pub-RT.id
}

# elastic ip
resource "aws_eip" "elastic_ip" {
  vpc = true
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_subnet.slack-pub-1,
    aws_eip.elastic_ip,
  ]
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.slack-pub-1.id

  tags = {
    Name = "nat-gateway"
  }
}
# Route table with target as NAT gateway
resource "aws_route_table" "slack-priv-RT" {
  depends_on = [
    aws_vpc.slack_vpc,
    aws_nat_gateway.nat_gateway,
  ]

  vpc_id = aws_vpc.slack_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet-1
resource "aws_route_table_association" "slack-priv-sub-1" {
  depends_on = [
    aws_subnet.slack-priv-1,
    aws_route_table.slack-priv-RT,
  ]
  subnet_id      = aws_subnet.slack-priv-1.id
  route_table_id = aws_route_table.slack-priv-RT.id
}

# associate route table to private subnet-1
resource "aws_route_table_association" "slack-priv-sub-2" {
  depends_on = [
    aws_subnet.slack-priv-2,
    aws_route_table.slack-priv-RT,
  ]
  subnet_id      = aws_subnet.slack-priv-2.id
  route_table_id = aws_route_table.slack-priv-RT.id
}



resource "aws_internet_gateway" "gateway" {

}
resource "aws_internet_gateway_attachment" "example" {
  internet_gateway_id = aws_internet_gateway.gateway.id
  vpc_id              = aws_vpc.vpc.id
}
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "lab_vpc"
  }
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "table_associationa" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet-a.id
}
resource "aws_route_table_association" "table_associationb" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet-b.id
}
resource "aws_route_table_association" "table_associationc" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet-c.id
}

resource "aws_subnet" "subnet-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs_subnet-a"
  }
}
resource "aws_subnet" "subnet-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs_subnet-b"
  }
}
resource "aws_subnet" "subnet-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs_subnet-c"
  }
}


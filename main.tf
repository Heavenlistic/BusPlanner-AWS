#To create the backend blocks will use an S3 bucket to store the tfstate
terraform {
  backend "s3" {
    bucket = "halifax-transit-tfstate"
    key    = "transit.tfstate"
    region = "us-east-1"
  }
  
  #To create the provider blocks will ensure that aws providers are set.
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# #To create VPC and CIDR with a /16 subnet range and tags to show which resources belong to what environment
resource "aws_vpc" "parkland-transit" {
  cidr_block                       = "192.168.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "busplanner-${var.environment}-vpc"
    Environment = var.environment
    Provisioner = "terraform"
  }
}

#To create the Internet gateway which depends on the VPC that MUST be created first
resource "aws_internet_gateway" "parkland-transit-vpc-gateway" {
  vpc_id = aws_vpc.parkland-transit.id

  tags = {
    Name        = "busplanner-${var.environment}-gw"
    Environment = var.environment
    Provisioner = "terraform"
  }

  depends_on = [
    aws_vpc.parkland-transit
  ]
}

#To create the route table which determine where network traffic from a subnet or gateway is directed.
resource "aws_route" "r" {
  route_table_id         = aws_vpc.parkland-transit.default_route_table_id
  gateway_id             = aws_internet_gateway.parkland-transit-vpc-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

#To create subnet 1 private subnet and 1public subnet
resource "aws_subnet" "privatesubnet" {
  vpc_id                  = aws_vpc.parkland-transit.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"

  tags = {
    Name        = "busplanner-${var.environment}-private_subnet"
    Environment = var.environment
    Provisioner = "terraform"
  }

  depends_on = [
    aws_vpc.parkland-transit
  ]
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.parkland-transit.id
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name        = "busplanner-${var.environment}-public_subnet"
    Environment = var.environment
    Provisioner = "terraform"
  }

  depends_on = [
    aws_vpc.parkland-transit
  ]
}

#To create Elastic IP is to ensure that there is one associated to the VPC for resources that need it
resource "aws_eip" "nat_eip_a" {
  vpc = true
}

#To create NAT gateway and Route Table which is associated with the VPC
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name        = "busplanner-${var.environment}-nat_gateway_a"
    Environment = var.environment
    Provisioner = "terraform"
  }
}

resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.parkland-transit.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name        = "busplanner-${var.environment}-private_route_table"
    Environment = var.environment
    Provisioner = "terraform"
  }
}

resource "aws_route_table_association" "privateroute_one" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privateroute.id
}

#To display the output ID
output "vpc_security_group_id" {
  value = aws_vpc.parkland-transit.default_security_group_id
}

output "vpcid" {
  value = aws_vpc.parkland-transit.id
}
# output "security-group-id" {
#   value = aws_security_group.allow_incoming.id
# }
# Create VPC
resource "aws_vpc" "coder_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CoderVPC"
  }
}

# Create a single public subnet and two private subnets in the same availability zone
resource "aws_subnet" "public_subnet" {
  count                   = 1
  vpc_id                  = aws_vpc.coder_vpc.id
  cidr_block              = "10.0.1.0/24" # Adjust the CIDR block as needed
  availability_zone       = var.az[0]     # Use the first availability zone

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${var.az[0]}"
  }
}

# Create private subnets in two different availability zones
resource "aws_subnet" "private_subnet" {
  count             = 4
  vpc_id            = aws_vpc.coder_vpc.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = count.index < 2 ? var.az[0] : var.az[1]

  tags = {
    Name = "PrivateSubnet-${element(var.az, count.index)}-${count.index + 1}"
  }
}
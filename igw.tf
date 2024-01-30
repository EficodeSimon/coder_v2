# Internet Gateway
resource "aws_internet_gateway" "coder_igw" {
  vpc_id = aws_vpc.coder_vpc.id

  tags = {
    Name = "coderInternetGateway"
  }
}
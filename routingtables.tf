# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.coder_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.coder_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Public route table association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet[0].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private route tables
resource "aws_route_table" "private_route_table" {
  count  = length(var.az)
  vpc_id = aws_vpc.coder_vpc.id

  tags = {
    Name = "PrivateRouteTable-${var.az[count.index]}"
  }
}

# Associate private route table with private subnets
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.az)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

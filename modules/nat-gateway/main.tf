# Request Elastic IP for NAT Gateway in Public Subnet AZ1 
resource "aws_eip" "eip_for_nat_gateway_az1" {
  vpc    = true

  tags   = {
    Name = "EIP - NAT Gateway AZ1"
  }
}

# Request Elastic IP for NAT Gateway in Public Subnet AZ2
resource "aws_eip" "eip_for_nat_gateway_az2" {
  vpc    = true

  tags   = {
    Name = " EIP - NAT Gateway AZ2"
  }
}

# Create NAT Gatway in Public Subnet AZ1
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip_for_nat_gateway_az1.id
  subnet_id     = var.public_subnet_az1_id

  tags   = {
    Name = "NAT Gateway in Public AZ1"
  }
  depends_on = [var.internet_gateway]
}

# Create NAT Gatway in Public Subnet AZ2
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = var.public_subnet_az2_id

  tags   = {
    Name = "NAT Gateway in Public AZ2"
  }

  depends_on = [var.internet_gateway]
}

# Create a Private route table in AZ1 and add route via NAT Gateway AZ1
resource "aws_route_table" "private_route_table_az1" {
  vpc_id            = var.vpc_id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway_az1.id
  }

  tags   = {
    Name = "Private Route table AZ1"
  }
}

# Private App Subnet AZ1 <-> Private Route table AZ1
resource "aws_route_table_association" "private_app_subnet_az1_route_table_az1_association" {
  subnet_id         = var.private_app_subnet_az1_id
  route_table_id    = aws_route_table.private_route_table_az1.id
}

# Private Data Subnet AZ1 <-> Private Route table AZ1
resource "aws_route_table_association" "private_data_subnet_az1_route_table_az1_association" {
  subnet_id         = var.private_data_subnet_az1_id
  route_table_id    = aws_route_table.private_route_table_az1.id
}

# Create a Private route table in AZ2 and add route via NAT Gateway AZ2
resource "aws_route_table" "private_route_table_az2" {
 vpc_id            = var.vpc_id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway_az2.id
  }

  tags   = {
    Name = "Private Route table AZ2"
  }
}

# Private App Subnet AZ2 <-> Private Route table AZ2
resource "aws_route_table_association" "private_app_subnet_az2_route_table_az2_association" {
 subnet_id         = var.private_app_subnet_az2_id
 route_table_id    = aws_route_table.private_route_table_az2.id
}

# Private Data Subnet AZ2 <-> Private Route table AZ2
resource "aws_route_table_association" "private_data_subnet_az2_route_table_az2_association" {
  subnet_id         = var.private_data_subnet_az2_id
  route_table_id    = aws_route_table.private_route_table_az2.id
}
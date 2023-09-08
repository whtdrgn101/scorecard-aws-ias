resource "aws_vpc" "sc_vpc" {
 cidr_block = "10.0.0.0/16"
 enable_dns_support = true
 enable_dns_hostnames = true

 tags = {
   Name = "${var.environment}-vpc"
 }
}

resource "aws_subnet" "sc_public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.sc_vpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 tags = {
   Name = "${var.environment} Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "sc_private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.sc_vpc.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 tags = {
   Name = "${var.environment} Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "sc_gw" {
 vpc_id = aws_vpc.sc_vpc.id
 
 tags = {
   Name = "${var.environment} Project VPC IG"
 }
}

resource "aws_route_table" "sc_second_rt" {
 vpc_id = aws_vpc.sc_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.sc_gw.id
 }
 
 tags = {
   Name = "${var.environment} 2nd Route Table"
 }
}

resource "aws_route_table_association" "sc_public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.sc_public_subnets[*].id, count.index)
 route_table_id = aws_route_table.sc_second_rt.id
}
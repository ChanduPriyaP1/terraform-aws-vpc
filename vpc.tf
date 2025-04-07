# VPC Creation
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
       Name = local.resource-name
    }
  )
}

# Internet Gate way (IGW) Creation
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.resource-name
    }
  )
}

# Subnets Creation Public, Private, Database.
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  availability_zone = local.az_zones[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_cidr_tags,
    {
        Name = "${var.project_name}-public-${local.az_zones[count.index]}" #expence-public-us-east-1a or 1b
    }
  )
}  

# Subnets Creation Public, Private, Database.
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  availability_zone = local.az_zones[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
        Name = "${var.project_name}-private-${local.az_zones[count.index]}" #expence-private-us-east-1a or 1b
    }
  )
}

# Subnets Creation Public, Private, Database.
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  availability_zone = local.az_zones[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidr_tags,
    {
        Name = "${var.project_name}-database-${local.az_zones[count.index]}" #expence-private-us-east-1a or 1b
    }
  )
}
# DB Subnets Groups
resource "aws_db_subnet_group" "data" {
  name       = "${local.resource-name}"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.aws_db_subnet_group_tags,
    {
       Name = "${local.resource-name}"
  }
  )
}

# Elastic IP creation
resource "aws_eip" "nat" {
  domain   = "vpc"
}

# NAT Gateway Creation
resource "aws_nat_gateway" "nat_gate" {
  allocation_id = aws_eip.nat.id # Attach Elastic IP to NAT Gateway
  subnet_id     = aws_subnet.public[0].id

  tags =merge(
    var.common_tags,
    var.nat_tags,
    {
      Name = "${local.resource-name}-Nat"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw] #This is explicit dependency
}

# public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_rt_tags,
    {
    Name = "${local.resource-name}-public-rt"
  
  }
  )
}

# private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_rt_tags,
    {
    Name = "${local.resource-name}-private-rt"
  
  }
  )
}

# database route table
resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_rt_tags,
    {
    Name = "${local.resource-name}-database-rt" # expence-database-rt
  
  }
  )
}

#  Public Route
resource "aws_route" "public_r" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

#  Private Route
resource "aws_route" "private_r" {
  route_table_id            = aws_route_table.private_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gate.id
}

#  database Route
resource "aws_route" "database_r" {
  route_table_id            = aws_route_table.database_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gate.id
}
# Route Table To Public subnet Association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  # [*].id → This means "Get a list of all the subnet IDs" from the aws_subnet.public resource.
  # element(list, index) is a Terraform function that picks a specific item from a list based on an index.
  route_table_id = aws_route_table.public_rt.id
}

# Route Table To Private subnet Association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

# Route Table To Private subnet Association
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database_rt.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Create a VPC to launch build instances into
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = local.k8s.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  #  instance_tenancy     = "default"

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "tbc.eks.vpc.${local.project.slug}"
  }

}
# ----------------------------------------------------------------------------------------------------------------------
# elastic ip
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "main" {
  vpc  = true
  tags = {
    "Name" = "tbc.eks.eip.${local.project.slug}",
  }
  depends_on = [aws_vpc.main]
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id     = aws_vpc.main.id
  #  depends_on = var.depending_by
  depends_on = [
    aws_vpc.main
  ]
  tags = {
    Name = "tbc.eks.igw.${local.project.slug}"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# NAT gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_nat_gateway" "main" {
  depends_on = [
    aws_eip.main,
  ]
  allocation_id = aws_eip.main.id
  subnet_id     = element(aws_subnet.public[*].id, 0)

  tags = {
    Name = "tbc.eks.nat-gateway.${local.project.slug}"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create dhcp option setup
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "eu-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = {
    Name = "tbc.eks.dhcp-options.${local.project.slug}"
  }
  depends_on = [
    aws_vpc.main
  ]
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index +  1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  map_public_ip_on_launch = true

  tags = {
    "Name"                                        = "tbc.eks.subnet.public.${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${local.project.slug}" = "owned",
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create dhcp option setup
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "privates" {
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index +  length(data.aws_availability_zones.available.names)+1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  map_public_ip_on_launch = false

  tags = {
    "Name"                                        = "tbc.eks.subnet.public.${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${local.project.slug}" = "owned",
  }
}


# ----------------------------------------------------------------------------------------------------------------------
# route table with target as internet gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "tbc.eks.route.table.private.${local.project.slug}"
  }

}


# ----------------------------------------------------------------------------------------------------------------------
# associate route table to public subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.privates.*.id)
  subnet_id      = element(aws_subnet.privates.*.id, count.index)
  route_table_id = aws_route_table.private.id
  depends_on     = [
    aws_route_table.private
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# route table with target as internet gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "tbc.eks.route.table.public.${local.project.slug}."
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# associate route table to public subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
  depends_on     = [
    aws_route_table.public
  ]
}
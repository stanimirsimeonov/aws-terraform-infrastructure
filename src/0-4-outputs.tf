
# The ID of the VPC
output "vpc-id" {
  value = aws_vpc.main.id
}
#  Amazon Resource Name (ARN) of VPC
output "kms-key" {
  value = aws_kms_key.main.key_id
}

output "kms-arn" {
  value = aws_kms_key.main.arn
}

output "kms-alias-arn" {
  value = aws_kms_alias.main.arn
}

output "target_key_arn" {
  value = aws_kms_alias.main.target_key_arn
}

output "vpc-arn" {
  value = aws_vpc.main.arn
}
# The ID of the AWS account that owns the VPC.
output "vpc-owner_id" {
  value = aws_vpc.main.owner_id
}
# Whether or not the VPC has DNS support
output "vpc-enable_dns_support" {
  value = aws_vpc.main.enable_dns_support
}

# The ID of the main route table associated with this VPC. Note that you can change a VPC's main route table by using an aws_main_route_table_association
output "vpc-main_route_table_id" {
  value = aws_vpc.main.main_route_table_id
}
# The ID of the route table created by default on VPC creation
output "vpc-default_route_table_id" {
  value = aws_vpc.main.default_route_table_id
}
# The IPv4 CIDR block for the VPC.
output "vpc-cidr_block" {
  value = aws_vpc.main.cidr_block
}
output "vpc-default_security_group_id" {
  value = aws_vpc.main.default_security_group_id
}



# The ID of the Internet Gateway.
output "ign-id" {
  value = aws_internet_gateway.main.id
}

# The ARN of the Internet Gateway.
output "ign-arn" {
  value = aws_internet_gateway.main.arn
}

# The ID of the AWS account that owns the internet gateway.
output "ign-owner_id" {
  value = aws_internet_gateway.main.owner_id
}

# ----------------------------------------------------------------------------------------------------------------------
# Elastic IPs
# ----------------------------------------------------------------------------------------------------------------------
# Contains the EIP allocation ID.
output "eip-id" {
  value = aws_eip.main.id
}
# The Private DNS associated with the Elastic IP address (if in VPC).
output "eip-private_dns" {
  value = aws_eip.main.private_dns
}

# Contains the private IP address (if in VPC).
output "eip-private_ip" {
  value = aws_eip.main.private_ip
}
# Contains the public IP address.
output "eip-public_ip" {
  value = aws_eip.main.public_ip
}

#  Public DNS associated with the Elastic IP address.
output "eip-public_dns" {
  value = aws_eip.main.public_dns
}

# Indicates if this EIP is for use in VPC (vpc) or EC2-Classic (standard).
output "eip-domain" {
  value = aws_eip.main.domain
}

# Carrier IP address.
output "eip-carrier_ip" {
  value = aws_eip.main.carrier_ip
}

# Customer owned IP.
output "eip-customer_owned_ip" {
  value = aws_eip.main.customer_owned_ip
}

# ID representing the association of the address with an instance in a VPC.
output "eip-association_id" {
  value = aws_eip.main.association_id
}

#  ID that AWS assigns to represent the allocation of the Elastic IP address for use with instances in a VPC.
output "eip-allocation_id" {
  value = aws_eip.main.allocation_id
}
# ----------------------------------------------------------------------------------------------------------------------
# NAT Gateway
# ----------------------------------------------------------------------------------------------------------------------
# The ID of the NAT Gateway.
output "nat-gw-id" {
  value = aws_nat_gateway.main.id
}

#  The Allocation ID of the Elastic IP address for the gateway.
output "nat-gw-allocation_id" {
  value = aws_nat_gateway.main.allocation_id
}

# The Subnet ID of the subnet in which the NAT gateway is placed.
output "nat-gw-subnet_id" {
  value = aws_nat_gateway.main.subnet_id
}

# The ENI ID of the network interface created by the NAT gateway.
output "nat-gw-network_interface_id" {
  value = aws_nat_gateway.main.network_interface_id
}

# The private IP address of the NAT Gateway.
output "nat-gw-private_ip" {
  value = aws_nat_gateway.main.private_ip
}

# The public IP address of the NAT Gateway.
output "nat-gw-public_ip" {
  value = aws_nat_gateway.main.public_ip
}


# ----------------------------------------------------------------------------------------------------------------------
# PUBLIC SUBNETS
# ----------------------------------------------------------------------------------------------------------------------
output "public-subnet-id" {
  value = aws_subnet.public.*.id
}

output "public-subnet-arn" {
  value = aws_subnet.public.*.arn
}

output "public-subnet-owner_id" {
  value = aws_subnet.public.*.owner_id
}

output "public-subnet-tags_all" {
  value = aws_subnet.public.*.tags_all
}

output "public-subnet-availability_zone" {
  value = aws_subnet.public.*.availability_zone
}

# ----------------------------------------------------------------------------------------------------------------------
# PRIVATE SUBNETS
# ----------------------------------------------------------------------------------------------------------------------
output "privates-subnet-id" {
  value = aws_subnet.privates.*.id
}

output "privates-subnet-arn" {
  value = aws_subnet.privates.*.arn
}

output "privates-subnet-owner_id" {
  value = aws_subnet.privates.*.owner_id
}

output "privates-subnet-tags_all" {
  value = aws_subnet.privates.*.tags_all
}

output "privates-subnet-availability_zone" {
  value = aws_subnet.privates.*.availability_zone
}

# ----------------------------------------------------------------------------------------------------------------------
# PRIVATE ROUTING
# ----------------------------------------------------------------------------------------------------------------------
# The ID of the routing table.
output "routing-table-private-id" {
  value = aws_route_table.private.id
}

# The ARN of the route table.
output "routing-table-private-arn" {
  value = aws_route_table.private.arn
}

# The ID of the AWS account that owns the route table.
output "routing-table-private-owner_id" {
  value = aws_route_table.private.owner_id
}

# The ID of the association
output "routing-table-private-assoc-id" {
  value = aws_route_table_association.private.*.id
}

# ----------------------------------------------------------------------------------------------------------------------
# PUBLIC ROUTING
# ----------------------------------------------------------------------------------------------------------------------
# The ID of the routing table.
output "public-table-private-id" {
  value = aws_route_table.private.id
}

# The ARN of the route table.
output "public-table-private-arn" {
  value = aws_route_table.private.arn
}

# The ID of the AWS account that owns the route table.
output "public-table-private-owner_id" {
  value = aws_route_table.private.owner_id
}

# The ID of the association
output "public-table-private-assoc-id" {
  value = aws_route_table_association.private.*.id
}


# ----------------------------------------------------------------------------------------------------------------------
# EKS CLuster
# ----------------------------------------------------------------------------------------------------------------------
output "eks-endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks-kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}
output "eks-name" {
  value = aws_eks_cluster.main.name
}
output "eks-id" {
  value = aws_eks_cluster.main.id
}

output "eks-tls_issuer" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "eks-identity" {
  value = aws_eks_cluster.main.identity[0]
}

output "eks-openid-provider-url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "eks-openid-provider-arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "domain" {
  value = data.aws_route53_zone.main.id
}


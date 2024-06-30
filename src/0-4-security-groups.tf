# ----------------------------------------------------------------------------------------------------------------------
# Setup a default SG group which deny everything
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags   = {
    Name : "tbc.eks.sg.default.${local.project.slug}"
  }
  depends_on = [
    aws_vpc.main
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Setup a SG group for RDS
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id
  name   = "${title(local.project.slug)}@RDS"

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
  tags = {
    Name : "tbc.eks.sg.rds.${local.project.slug}"
  }
  depends_on = [
    aws_vpc.main
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Setup a SG group for Redis
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "redis" {
  vpc_id = aws_vpc.main.id
  name   = "${title(local.project.slug)}@ElasticRedisSG$"
  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
  tags = {
    Name : "tbc.eks.sg.redis.${local.project.slug}"
  }
  depends_on = [
    aws_vpc.main
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Setup a SG group for Bastion
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id
  name   = "${title(local.project.slug)}@BastionSecurityGroup"
  description = "The security group is managing the traffic for the instance of EC2 used for private network accessing"
  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
  tags = {
    Name : "tbc.ec2.sg.bastion.${local.project.slug}"
  }
}


# ----------------------------------------------------------------------------------------------------------------------
# Allow ALL the   outgoing from VPC traffic to the outside world
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_all_outgoing" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_default_security_group.default.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ----------------------------------------------------------------------------------------------------------------------
# Allow the HTTP AND HTTPS traffic to the VPC
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_all_incoming_http" {
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  security_group_id = aws_default_security_group.default.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_incoming_https" {
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  security_group_id = aws_default_security_group.default.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ----------------------------------------------------------------------------------------------------------------------
# Allow incoming RDS traffic
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_all_incoming_pgsql" {
  from_port         = 5432
  to_port           = 5432
  protocol          = "TCP"
  security_group_id = aws_security_group.rds.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [
    aws_security_group.rds
  ]

}

# ----------------------------------------------------------------------------------------------------------------------
# Allow outgoing RDS traffic
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_all_outgoing_pgsql" {
  from_port         = 5432
  to_port           = 5432
  protocol          = "TCP"
  security_group_id = aws_security_group.rds.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [
    aws_security_group.rds
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Allow incoming REDIS traffic
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_all_incoming_redis" {
  from_port         = 6379
  to_port           = 6379
  protocol          = "TCP"
  security_group_id = aws_security_group.redis.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [
    aws_security_group.redis
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# Allow outgoing REDIS traffic
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_all_outgoing_redis" {
  from_port         = 6379
  to_port           = 6379
  protocol          = "TCP"
  security_group_id = aws_security_group.redis.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [
    aws_security_group.redis
  ]
}

# If allow_all_outbound is true, add a rule to allow all outbound
# traffic to Internet
resource "aws_security_group_rule" "bastion-outbound" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = format ("Allow all outbound traffic for Bastion EC2 instance")
}

resource "aws_security_group_rule" "bastion-inbound" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]

}
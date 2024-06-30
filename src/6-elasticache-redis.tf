# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_elasticache_subnet_group" "redis" {
  subnet_ids = aws_subnet.privates.*.id
  name       = "tbcp-elasticache-redis-subnet-group-${local.project.slug}"
  tags       = {
    Name : "tbc.elasticache.redis.subnet-group.${local.project.slug}"
  }
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_elasticache_cluster" "redis" {
  for_each = {for redis_config in var.REDIS_INSTANCES : redis_config.name => redis_config}

  cluster_id           = each.value.name
  node_type            = each.value.instance_class
  num_cache_nodes      = each.value.num_cache_nodes
  port                 = each.value.port
  engine               = "redis"
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"

  #  preferred_availability_zones = ["eu-west-2a", "eu-west-2b"]

  security_group_ids = [aws_security_group.redis.id]
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
}

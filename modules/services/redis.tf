# ------------------------
# | ElastiCache (Redis)  |
# ------------------------

resource "aws_elasticache_subnet_group" "elasticache" {
  name		= "elasticache-subnet-group"
  description	= "Use the private subnet for ElastiCache instances."
  subnet_ids	= [var.private_subnet_id, var.private2_subnet_id]
}

resource "aws_elasticache_parameter_group" "magento_required" {
  name   = "magento-required"
  family = "redis6.x"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lfu"
  }
}

# Redis instance for backend caching
resource "aws_elasticache_replication_group" "redis-backend-cache" {
  automatic_failover_enabled    = true
  availability_zones            = [var.az1, var.az2]
  multi_az_enabled              = true
  engine                        = "redis"
  engine_version                = var.redis_engine_version
  replication_group_id          = "redis-backend-cache"
  replication_group_description = "Redis Replication Group"
  node_type                     = var.ec2_instance_type_redis_cache
  number_cache_clusters         = 2
  parameter_group_name          = aws_elasticache_parameter_group.magento_required.name
  subnet_group_name             = aws_elasticache_subnet_group.elasticache.name
  security_group_ids            = [aws_security_group.allow_redis_in.id]
  port                          = 6379
  at_rest_encryption_enabled    = true
  #transit_encryption_enabled    = true

  lifecycle {
    ignore_changes = [number_cache_clusters]
  }

  tags = {
    Name	= "magento-redis-backend-cache"
    Terraform	= "true"
  }
}

#resource "aws_elasticache_cluster" "redis-backend-cache-replica" {
#  count = 1

#  cluster_id           = "redis-backend-cache-${count.index}"
#  replication_group_id = aws_elasticache_replication_group.redis-backend-cache.id
#}

# Redis instance for sessions
resource "aws_elasticache_replication_group" "redis-sessions" {
  automatic_failover_enabled    = true
  availability_zones            = [var.az1, var.az2]
  multi_az_enabled              = true
  engine                        = "redis"
  engine_version                = var.redis_engine_version
  replication_group_id          = "redis-sessions"
  replication_group_description = "Redis Replication Group"
  node_type                     = var.ec2_instance_type_redis_session
  number_cache_clusters         = 2
  parameter_group_name          = aws_elasticache_parameter_group.magento_required.name
  subnet_group_name             = aws_elasticache_subnet_group.elasticache.name
  security_group_ids            = [aws_security_group.allow_redis_in.id]
  port                          = 6379
  at_rest_encryption_enabled    = true
  #transit_encryption_enabled    = true

  lifecycle {
    ignore_changes = [number_cache_clusters]
  }

  tags = {
    Name	= "magento-redis-sessions"
    Terraform	= "true"
  }
}

#resource "aws_elasticache_cluster" "redis-sessions-replica" {
#  count = 1

#  cluster_id           = "redis-sessions-1-${count.index}"
#  replication_group_id = aws_elasticache_replication_group.redis-sessions.id
#}




#resource "aws_elasticache_cluster" "redis-backend-cache" {
#  cluster_id           = "${var.environment}-redis-backend-cache"
#  engine               = "redis"
#  engine_version       = var.redis_engine_version
#  node_type            = var.ec2_instance_type_redis_cache
#  num_cache_nodes      = 1
#  parameter_group_name = aws_elasticache_parameter_group.magento_required.name 
#  port                 = 6379
#  subnet_group_name    = aws_elasticache_subnet_group.elasticache.name
#  security_group_ids   = [aws_security_group.allow_redis_in.id]
#  tags = {
#    Name	= "magento-redis-backend-cache"
#    Terraform	= "true"
#    Environment = var.environment
#  }
#}

# Redis instance for sessions

#resource "aws_elasticache_cluster" "redis-sessions" {
#  cluster_id           = "${var.environment}-redis-sessions"
#  engine               = "redis"
#  engine_version       = var.redis_engine_version
#  node_type            = var.ec2_instance_type_redis_session
#  num_cache_nodes      = 1
#  parameter_group_name = aws_elasticache_parameter_group.magento_required.name 
#  port                 = 6379
#  subnet_group_name    = aws_elasticache_subnet_group.elasticache.name
#  security_group_ids   = [aws_security_group.allow_redis_in.id]
#  tags = {
#    Name	= "magento-redis-sessions"
#    Terraform	= "true"
#    Environment = var.environment
#  }
#}


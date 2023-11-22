terraform {
  backend "s3" {
    bucket = "lifi-terraform-prod-state"
    key    = "state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}


data "aws_caller_identity" "current" {}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

data "aws_iam_role" "ecr_admin_role" {
  name = "erc_admin_role"
}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  repository_url = "${local.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/lifi"
}

module "db" {
  source         = "../modules/db"
  identifier     = "rds-postgres-lifi-${var.environment}"
  instance_class = "db.t2.micro"

  name     = "todo" // db name
  username = var.postgres_user
  password = var.postgres_password
  port     = "5432"

  maintenance_window = "Mon:00:00-Mon:03:00"

  tags = {
    Environment = var.environment
  }

  vpc_id = module.network.vpc_id

  environment                = var.environment
  db_security_group_id       = module.sgs.rds_sg_id
  db_subnet_group_subnet_ids = module.network.public_subnets
  publicly_accessible        = true
}


module "service" {
  source                   = "../modules/service"
  environment              = var.environment
  region                   = var.region
  execution_role_arn       = data.aws_iam_role.ecr_admin_role.arn
  cluster_id               = module.ecs.ecs_cluster_id
  vpc_id                   = module.network.vpc_id
  lb_subnets               = module.network.public_subnets
  docker_image             = "${local.repository_url}:${var.image_tag}"
  container_family         = "lifi-service"
  health_check_path        = "/ping"
  container_port           = 3000
  loadbalancer_port        = 80
  cpu                      = 256
  memory                   = 512
  instance_count           = 1
  timeout                  = 180
  ingress_cdir_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cdir_blocks = []
  service_security_groups  = flatten([module.network.allow_all_sg, module.network.ecs_task_sg])
  container_env_vars = {
    POSTGRES_HOST     = module.db.db_instance_endpoint,
    POSTGRES_DB       = "todo",
    POSTGRES_USER     = var.postgres_user,
    POSTGRES_PASSWORD = var.postgres_password,
    REDIS_HOST        = "redis://default:${var.redis_password}@${module.cache.redis_instance_address}:${module.cache.redis_instance_port}",
  }
}

module "network" {
  source      = "../modules/networking"
  environment = var.environment
  cidr_block  = var.cidr_block
}

module "sgs" {
  source         = "../modules/sgs"
  environment    = var.environment
  ecs_task_sg_id = module.network.ecs_task_sg
  vpc_cdir_block = module.network.vpc_cdir_block
  vpc_id         = module.network.vpc_id
}


module "ecs" {
  source                  = "../modules/ecs"
  environment             = var.environment
  ecs_cluster_name_prefix = "lifi-ecs"
}


module "cache" {
  source                        = "../modules/redis"
  environment                   = var.environment
  sg_id                         = module.network.ecs_task_sg
  vpc_id                        = module.network.vpc_id
  cache_subnet_group_subnet_ids = module.network.public_subnets
  node_type                     = "cache.t2.micro"
  public_redis                  = true
}

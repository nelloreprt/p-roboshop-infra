module "vpc" {
  source = /"git::https://github.com/nelloreprt/p-tf-module-vpc.git"
  env = var.env
  tags = var.tags

  for_each = var.vpc
  vpc_cidr_block       = each.value["vpc_cidr_block"]
  public_subnets = each.value["public_subnets"]
  private_subnets = each.value["private_subnets"]

  default_vpc_id = var.default_vpc_id
  default_route_table_id = var.default_route_table_id

}

output "public_subnets" {
  value = "module.vpc"
}

#---------------------------------------------------------
module "docdb" {
  source = "git::https://github.com/nelloreprt/p-tf-module-docdb.git"
  env = var.env
  tags = var.tags

  for_each = var.docdb
  engine                  = each.value["engine"]
  backup_retention_period = each.value["backup_retention_period"]
  preferred_backup_window = each.value["preferred_backup_window"]
  skip_final_snapshot     = each.value["skip_final_snapshot"]

  engine_version = each.value["engine_version"]
  subnet_ids = local.db_subnet_ids

  count = each.value["count"]
  instance_class = each.value["instance_class"]

  # for docdb (security_group)
  vpc_id = module.vpc["main"].vpc_id

  cidr_block = local.cidr_blocks[each.value["subnet_name"]]
}

# for doc_db
output "private_subnets" {
  value = "module.vpc"
}

#---------------------------------------------------------
module "rds" {
  source = "git::https://github.com/nelloreprt/p-tf-module-rds.git"
  env = var.env
  tags = var.tags

  for_each = var.rds
  engine                  = each.value["engine"]
  engine_version = each.value["engine_version"]
  backup_retention_period = each.value["backup_retention_period"]
  preferred_backup_window = each.value["preferred_backup_window"]

  subnet_ids = local.db_subnet_ids

  count = each.value["count"]
  instance_class = each.value["instance_class"]

  # for elasticache (security_group)
  vpc_id = module.vpc["main"].vpc_id

  cidr_block = local.cidr_blocks[each.value["subnet_name"]]
}

#------------------------------------------------------
module "elasticache" {
  source = "git::https://github.com/nelloreprt/p-tf-module-elasticache.git"
  env = var.env
  tags = var.tags

  for_each = var.elasticache
  engine               = each.value["engine"]
  node_type            = each.value["node_type"]
  num_cache_nodes      = each.value["num_cache_nodes"]
  parameter_group_name = each.value["parameter_group_name"]
  engine_version       = each.value["engine_version"]
  port                 = each.value["port"]

  subnet_ids = local.db_subnet_ids

  # for elasticache (security_group)
  vpc_id = module.vpc["main"].vpc_id

  cidr_block = local.cidr_blocks[each.value["subnet_name"]]
}

# for endpoint_elasticache
output "elasticache-endpoint" {
value = "module.elasticache"
}

#------------------------------------------------------
module "rabbitmq" {
  source = "git::https://github.com/nelloreprt/p-tf-module-rabbitmq.git"
  env = var.env
  tags = var.tags

  for_each = var.rabbitmq
  instance_type = each.value["instance_type"]

  subnet_ids = local.db_subnet_ids

  # for rabbitmq (security_group)
  vpc_id = module.vpc["main"].vpc_id

  cidr_block = local.cidr_blocks[each.value["subnet_name"]]

  bastion_cidr = var.bastion_cidr
  dns_domain = var.dns_domain
}

#------------------------------------------------------
module "alb" {
  source = "git::https://github.com/nelloreprt/p-tf-module-alb.git"
  env = var.env
  tags = var.tags

  for_each = var.alb
  name               = each.value["name"]
  internal           = each.value["internal"]
  load_balancer_type = each.value["load_balancer_type"]
  enable_deletion_protection = each.value["enable_deletion_protection"]

  # attaching private_subnet_ids to private_alb, attaching public_subnet_ids to public_alb
  subnet_ids = local.alb_subnet_ids[each.value["subnet_name"]]

  # for LB (security_group)
  vpc_id = module.vpc["main"].vpc_id

  cidr_block = each.value["cidr_block"]
}

#------------------------------------------------------
module "app" {
  source = "git::https://github.com/nelloreprt/p-tf-module-app.git"
  env = var.env
  tags = var.tags

  for_each = var.app
  component = each.value["component"]
  instance_type = each.value["instance_type"]
  desired_capacity   = each.value["desired_capacity"]
  max_size           = each.value["max_size"]
  min_size           = each.value["min_size"]

  # attaching private_subnet_ids to private_alb, attaching public_subnet_ids to public_alb
  # without_lookup also it will work
  subnet_ids = lookup(local.asg_subnet_ids, [each.value["subnet_name"]] , null)

  vpc_id = module.vpc["main"].vpc_id

  bastion_cidr = var.bastion_cidr

  port = each.value["port"]
  cidr_block = lookup(local.cidr_block,  [each.value["cidr_block"]] , null)

  dns_domain = var.dns_domain

  # fetched with output_block_alb # for every map >> one lookup is added
  alb_records = lookup(lookup(lookup(module.alb, each.value["alb_records"], null) "alb" , null) "dns_name" , null)
  # hint: 1st lookup >> public/private, null
  #       2nd lookup >> alb, null
  #       3rd lookup >> dns_name, null

  listener_arn = lookup(lookup(lookup(module.listener_arn, each.value["alb_records"] , null) "listner" ,null) "arn" , null )
  listener_priority = each.value["listener_priority"]

  parameters = each.value["parameters"]

  depends_on : [module.docdb, module.elasticache, module.rabbitmq, module.rds, module.alb]
  # we are making database to get created first, only after which app.module will get created
}

# for vpc_id
output "vpc_id" {
value = "module.vpc"
}

# value for >> " alb_dns_domain " >> is formulated using
output "alb" {
value = "module.alb"
}

# for listener_arn >> is formulated using
output "listener_arn" {
value = "module.alb.listener"
}












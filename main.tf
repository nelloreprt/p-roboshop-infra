module "vpc" {
  source = "git::https://github.com/nelloreprt/p-tf-module-vpc.git"
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
}

#------------------------------------------------------
module "rabbitmq" {
  source = "git::https://github.com/nelloreprt/p-tf-module-rabbitmq.git"
  env = var.env
  tags = var.tags

  for_each = var.rabbitmq
  instance_type = each.value["instance_type"]

  subnet_ids = local.db_subnet_ids
}
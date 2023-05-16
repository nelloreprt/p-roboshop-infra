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
# locals.tf >> these variables will get declared while running terraform_apply
# locals.tf is a variable will come when you do terraform apply,
# so locals.tf file shall be made available in root/parent folder
# these are not predefined/user variable

locals {

  # Syntax: module.module_name.output_block_name
  # private_subnets_id = [ module.vpc["main"].private_subnets["db-az1"].id , module.vpc["main"].private_subnets["db-az1"].id ]
  # above output will come as a string

  # we need to convert string_output to list
                   # Syntax: module.module_name.output_block_name
  db_subnet_ids =  tolist([ "module.vpc["main"].private_subnet_id["db-az1"].id" , "module.vpc["main"].private_subnet_id["db-az2"].id" ])
  web_subnet_ids =  tolist([ "module.vpc["main"].private_subnet_id["web-az1"].id" , "module.vpc["main"].private_subnet_id["web-az2"].id" ])
  app_subnet_ids =  tolist([ "module.vpc["main"].private_subnet_id["app-az1"].id" , "module.vpc["main"].private_subnet_id["app-az2"].id" ])

  alb_subnet_ids = {
  public = tolist([ "module.vpc["main"].public_subnet_id["public-az1"].id" , "module.vpc["main"].public_subnet_id["public-az2"].id" ])
  app = tolist([ "module.vpc["main"].private_subnet_id["app-az1"].id" , "module.vpc["main"].private_subnet_id["app-az2"].id" ])
}

  asg_subnet_ids = {
    app = tolist([ "module.vpc["main"].private_subnet_id["app-az1"].id" , "module.vpc["main"].private_subnet_id["app-az2"].id" ])
    web = tolist([ "module.vpc["main"].private_subnet_id["web-az1"].id" , "module.vpc["main"].private_subnet_id["web-az2"].id" ])
  }
}


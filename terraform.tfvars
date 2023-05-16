# we are going to add tags which is common for both the environments
# all variables in terraform.tfvars will be automatically picked up by terraform

tags = {
  bu_unit_name = "ecommerce"
  app_name     = "roboshop"
  owner        = "ecom_bu"
  cost_center  = 1001
}

# both default_vpc_id & route_table_id are common for both dev & prod environment,
# all variables in terraform.tfvars will be automatically picked up by terraform
default_vpc_id = "vpc-049695961c2b3023a"
default_route_table_id = "rtb-08fd5b2155fad8288"

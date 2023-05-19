variable "vpc" {}
variable "env" {}
variable "tags" {}

variable "default_route_table_id" {}
variable "default_vpc_id" {}

# docdb------------------
variable "docdb" {}

# rds--------------
variable "rds" {}

# elasticache=redis
variable "elasticache" {}

# rabbitmq----------------------
variable "rabbitmq" {}

# alb--------------------------
variable "alb" {}

# app---------------------------
variable "app" {}

# bastion_cidr------------------
variable "bastion_cidr" {}

# dns_domain for CNAME
variable "dns_domain" {}
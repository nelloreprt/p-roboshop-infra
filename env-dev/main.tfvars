env = "dev"

dns_domain = "nellore.online"

bastion_cidr = ["172.168.0.1/32"]
# 172.168.0.1 >> this is the pvt_ip address of workstation/bastion
# we are adding /32 >> meaning >> one single_ip
# /24 >> 256 ips
# /16 >> 65,000 ips

# the basis for this file creation is arguments of VPC and its components
vpc = {
  main = {
    vpc_cidr_block       = "10.0.0.0/16"

    public_subnets = {

      public-az1 = {
        cidr_block = [ "10.0.0.0/24"]
        availability_zone = "us-east-1a"
        name = public-az1
      }

      public-az2 = {
        cidr_block = [ "10.0.1.0/24" ]
        availability_zone = "us-east-1b"
        name = public-az2
      }
    }

    private_subnets = {
      web-az1 = {
        cidr_block = ["10.0.2.0/24"  ]
        name = "web-az1"
        availability_zone = "us-east-1a"
      }

      web-az2 = {
        cidr_block = [ "10.0.3.0/24" ]
        name = "web-az2"
        availability_zone = "us-east-1b"
      }

      app-az1 = {
        cidr_block = ["10.0.4.0/24"  ]
        name = "app-az1"
        availability_zone = "us-east-1a"
      }

      app-az2 = {
        cidr_block = [ "10.0.5.0/24" ]
        name = "app-az2"
        availability_zone = "us-east-1b"
      }


      db-az1 ={
        cidr_block = ["10.0.6.0/24"  ]
        name = "db-az1"
        availability_zone = "us-east-1a"
      }

      db-az2 ={
        cidr_block = [ "10.0.7.0/24" ]
        name = "db-az2"
        availability_zone = "us-east-1b"
      }
    }
  }
}

# doc-db
# use-case-1
# currently for all the components we are using single_common database
docdb = {
  main = {
    engine                  = "docdb"
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    skip_final_snapshot     = true

    engine_version = "4.0.0"

    count              = 2
    instance_class     = "db.r5.large"

    components in app_subnet will access the docdb
    subnet_name = "app"   # cidr_block not subnet_id
  }
}

# use-case-2 (ignore)
# suppose if projject_architecture requirement is that
# component shall have docdb separately, user shall have docdb separately
docdb = {
  catalogue = {
    engine                  = "docdb"
    master_username         = "foo"
    master_password         = "mustbeeightchars"
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
  }

  user = {
    engine                  = "docdb"
    master_username         = "foo"
    master_password         = "mustbeeightchars"
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
  }
}

# rds_database
rds = {
  main = {
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.03.2"
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    count              = 2
    instance_class     = "db.r4.large"

    components in app_subnet will access the RDS
    subnet_name = "app"   # cidr_block not subnet_id
  }
}

# elasticache ()
elasticache = {
  main = {
    engine               = "redis"
    node_type            = "cache.m4.large"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis3.2"
    engine_version       = "3.2.10"
    port                 = 6379

    components in app_subnet will access the ELASTICACHE
    subnet_name = "app"   # cidr_block not subnet_id
  }
}

rabbitmq = {
  main = {
    instance_type = "t3.small"

    components in app_subnet will access the RABBITMQ
    subnet_name = "app"   # cidr_block not subnet_id
  }
}

# Application_Load_Balancer-----------------------

alb = {
  public = {
    name               = "public_alb"
    internal           = false
    load_balancer_type = "application"
    enable_deletion_protection = true

    # attaching public_subnet_ids to public_alb
    subnet_name = public

    # we are allowing outside world to access Public_Load_balancer
    cidr_block = [ "0.0.0.0/0"]
  }

  private = {
    name               = "private_alb"
    internal           = true
    load_balancer_type = "application"
    enable_deletion_protection = true

    # attaching private_subnet_ids to private_alb
    subnet_name = app

    LB in app_subnet will be accessed by [app_subnets + web_subnets]
    cidr_block = [ "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  }
}

# app---------------------------------------
app = {
  catalogue = {
    component = catalogue
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app

    # we are opening within the app only
    # and we are allowing other components in (app)Private_subnets to access catalogue
    # so we are opening port 8080 in catalogue
    port = 8080

    # we are allowing catalogue to Private_subnet
    # (app)Private_subnets shall be in a position to access catalogue
    cidr_block = app

    #    I.e Load_Balancer name we will give in C_Name reord
    #    using CNAME of Route53 >> cname = name to name
    alb_records = private

    listener_priority = 10

    parameters = [ "docdb" ]  # this information will be known from project by checking each and every component
  }

  cart = {
    component = cart
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app

    # we are opening within the app only
    # and we are allowing other components in (app)Private_subnets to access cart
    # so we are opening port 8080 in cart
    port = 8080

    # we are allowing cart to Private_subnet
    # (app)Private_subnets shall be in a position to access cart
    cidr_block = app

    #    I.e Load_Balancer name we will give in C_Name reord
    #    using CNAME of Route53 >> cname = name to name
    alb_records = private

    listener_priority = 11
    parameters = [ "elasticache" ]  # this information will be known from project by checking each and every component

  }

  user = {
    component = user
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app

    # we are opening within the app only
    # and we are allowing other components in (app)Private_subnets to access user
    # so we are opening port 8080 in user
    port = 8080

    # we are allowing user to Private_subnet
    # (app)Private_subnets shall be in a position to access user
    cidr_block = app

    #    I.e Load_Balancer name we will give in C_Name reord
    #    using CNAME of Route53 >> cname = name to name
    alb_records = private

    listener_priority = 12
    parameters = [ "docdb" , "elasticache" ]  # this information will be known from project by checking each and every component

  }

  shipping = {
    component = shipping
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app

    # we are opening within the app only
    # and we are allowing other components in (app)Private_subnets to access shipping
    # so we are opening port 8080 in shipping
    port = 8080

    # we are allowing shipping to Private_subnet
    # (app)Private_subnets shall be in a position to access shipping
    cidr_block = app

    #    I.e Load_Balancer name we will give in C_Name reord
    #    using CNAME of Route53 >> cname = name to name
    alb_records = private

    listener_priority = 13
    parameters = [ "rds"  ]  # this information will be known from project by checking each and every component

  }

  payment = {
    component = payment
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app

    # we are opening within the app only
    # and we are allowing other components in (app)Private_subnets to access payment
    # so we are opening port 8080 in Payment
    port = 8080

    # we are allowing Payment to Private_subnet
    # (app)Private_subnets shall be in a position to access payment
    cidr_block = app

    #    I.e Load_Balancer name we will give in C_Name reord
    #    using CNAME of Route53 >> cname = name to name
    alb_records = private

    listener_priority = 14
    parameters = [ ]  # this information will be known from project by checking each and every component

  }

  frontend = {
    component = frontend
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = web


    # so we are opening port 80 in frontend
    port = 80

    # we are allowing frontend to Public_subnet
    # public_subnets shall be in a position to access frontend
    cidr_block = public  # public_subnet should access the frontend

    #    I.e Load_Balancer name we will give in C_Name reord
    #    using CNAME of Route53 >> cname = name to name
    alb_records = public

    listener_priority = 10

    parameters = [ ]  # this information will be known from project by checking each and every component

  }
}



















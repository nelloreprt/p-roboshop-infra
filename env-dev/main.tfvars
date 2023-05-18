env = "dev"

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
  }
}

rabbitmq = {
  main = {
    instance_type = "t3.small"
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
  }

  private = {
    name               = "private_alb"
    internal           = true
    load_balancer_type = "application"
    enable_deletion_protection = true

    # attaching private_subnet_ids to private_alb
    subnet_name = app
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
  }

  cart = {
    component = cart
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app
  }

  user = {
    component = user
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app
  }

  shipping = {
    component = shipping
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app
  }

  payment = {
    component = payment
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = app
  }

  frontend = {
    component = frontend
    instance_type = "t3.micro"
    desired_capacity   = 2
    max_size           = 6
    min_size           = 2

    # attaching private_subnet_ids to private_asg
    subnet_name = web
  }
}



















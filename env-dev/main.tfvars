env = "dev"

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
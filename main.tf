terraform {
  required_version = ">=0.12"
  backend "s3" {
    bucket = "mysql-jenkins-2-pet"
    key    = "myapp/state.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region     = "eu-central-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_sidr_block

  azs             = [var.avail_zone] 
  public_subnets  = [var.subnet_sidr_block]
  public_subnet_tags = { Name = "${var.env_prefix}-subnet-1" }


  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-server" {
  source  = "./modules/webserver"
  my_ip = var.my_ip
  vpc_id = module.vpc.vpc_id
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  image_name = var.image_name
  subnet_id = module.vpc.public_subnets[0]

}

/*data "aws_vpc" "existing_vpc" {
    default = true # This is only the default VPC
}


resource "aws_subnet" "dev-subnet-2" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.48.0/20"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "dev-subnet-1"
  }
}*/
provider "aws" {
  region     = "eu-central-1"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_sidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }

}

module "myapp-subnet" {
  source  = "./modules/subnet"
  vpc_id = aws_vpc.myapp-vpc.id
  subnet_sidr_block = var.subnet_sidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source  = "./modules/webserver"
  my_ip = var.my_ip
  vpc_id = aws_vpc.myapp-vpc.id
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  image_name = var.image_name
  subnet_id = module.myapp-subnet.subnet.id #module.name_of_the_module.name_of_the_output_for_the_module.atribute

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
provider "aws" {
  region     = "eu-central-1"
}

variable "sidr_block" {
  description = "SIDR Blocks for VPC and Subnets"
  type = list(object({
    cidr_block = string
    name = string
  }))
}

variable avail_zone {}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.sidr_block[0].cidr_block

  tags = {
    Name = var.sidr_block[0].name
  }

}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id     = aws_vpc.development-vpc.id
  cidr_block = var.sidr_block[1].cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = var.sidr_block[1].name
  }
}

output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
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
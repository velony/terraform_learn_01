provider "aws" {
  region     = "eu-central-1"
}

variable "vpc_sidr_block" {}
variable "subnet_sidr_block" {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_sidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }

}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_sidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id      = aws_vpc.myapp-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22 # Defines range from 22 to 22 in this case
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip] #Which IP addresses are allowed to access
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }

  egress {
    from_port        = 0  # Configured for any
    to_port          = 0  # Configured for any
    protocol         = "-1" # Configured for any
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids = []

  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = "${file(var.public_key_location)}" # Can be: file(var.public_key_location) 
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  # availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  user_data = file ("entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent      = true
  owners = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
    filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
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
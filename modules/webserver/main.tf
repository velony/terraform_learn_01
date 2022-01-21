resource "aws_security_group" "myapp-sg" {
    vpc_id      = var.vpc_id
    name = "myapp-sg"

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
    Name = "${var.env_prefix}-myapp-sg"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = "${file(var.public_key_location)}" # Can be: file(var.public_key_location) 
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  # availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  user_data = file("entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent      = true
  owners = ["137112412989"]
  filter {
    name   = "name"
    values = [var.image_name]
  }
    filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
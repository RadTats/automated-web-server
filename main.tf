provider "aws" {
  skip_credentials_validation = true
}

variable "key_name" {
  description = "name of the key pair"
  default     = "key"
}

resource "aws_vpc" "webvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "web server VPC"
  }
}

resource "aws_security_group" "websg" {
  name        = "webSG"
  description = "Allows SSH and HTTP access to the web server"
  vpc_id      = aws_vpc.webvpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.webvpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webvpc.id
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.webvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "publicasso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_instance" "nginx" {
  instance_type               = "t2.micro"
  ami                         = "ami-0ad97c80f2dfe623b"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.websg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  user_data                   = file("init.sh")
  associate_public_ip_address = "true"
}
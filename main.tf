provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}


resource "aws_vpc" "default" {
  cidr_block = "10.10.0.0/16"
}


resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}


resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}


resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
}


resource "aws_security_group" "consul" {
  name        = "consul_server_sg"
  description = "consul_server"
  vpc_id      = "${aws_vpc.default.id}"

  
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_key_pair" "access" {
  key_name   = "chat_key"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "consul_server" {
  connection {
    user = "ubuntu"
  }
  count = 1
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_ami, var.region)}"
  key_name = "${aws_key_pair.access.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id = "${aws_subnet.default.id}"
  user_data = "${file(\"cloud-config/user-data.yml\")}"
  tags = { 
    Name = "consul-server-${count.index}"
  }
}

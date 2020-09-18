provider "aws" {
  region = var.region
}

resource "aws_key_pair" "jenkins" {
  key_name = "${var.name}_key"
  public_key = file(pathexpand(var.public_key))

  tags = {
    Name = "${var.name}-${var.release}"
    Version = var.release
  }
}


resource "aws_security_group" "jenkins" {
  name = "${var.name}_sg"
  description = "Allow ssh and web traffic"
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.whitelisted_ssh
  }
  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.whitelisted_web
  }
  ingress {
    description = "Allow HTTP"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = var.whitelisted_web
  }
  egress {
    description = "Allow all outbound!"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}-${var.release}"
    Version = var.release
  }
}


resource "aws_instance" "jenkins" {
  key_name = aws_key_pair.jenkins.key_name

  #  Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  ami = "ami-07efac79022b86107"
  instance_type = "t3.micro"

  tags = {
    Name = "${var.name}-${var.release}"
    Version = var.release
  }

  volume_tags = {
    Name = "${var.name}-${var.release}"
    Version = var.release
  }

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  provisioner "salt-masterless" {
    local_state_tree = "../../modules/salt/states"
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(pathexpand(var.private_key))
      host = self.public_ip
    }
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
  instance = aws_instance.jenkins.id

  tags = {
    Name = "${var.name}-${var.release}"
    Version = var.release
  }
}

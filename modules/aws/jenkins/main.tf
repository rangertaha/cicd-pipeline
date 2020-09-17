provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }

 # Canonical
  owners = ["099720109477"]

}


resource "aws_key_pair" "jenkins" {
  key_name = "${var.project}_key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  tags = {
    Name = "${var.project}_${var.release}"
    Version = var.release
    Project = var.project
  }
}

# allow incoming/outgoing connections to nginx server
resource "aws_security_group" "jenkins" {
  name = "${var.project}_sg"
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
  egress {
    description = "Allow all outbound!"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_${var.release}"
    Version = var.release
    Project = var.project
  }
}


resource "aws_instance" "jenkins" {
  key_name = aws_key_pair.jenkins.key_name
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "${var.project}_${var.release}"
    Version = var.release
    Project = var.project
  }

  volume_tags = {
    Name = "${var.project}_${var.release}"
    Version = var.release
    Project = var.project
  }

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  provisioner "salt-masterless" {
    local_state_tree = "../../modules/salt/states"
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(pathexpand("~/.ssh/id_rsa"))
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
    Name = "${var.project}_${var.release}"
    Version = var.release
    Project = var.project
  }
}
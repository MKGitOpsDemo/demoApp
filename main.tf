terraform {
  backend "s3" {
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

variable "region" {
    default = "us-east-1"
}

provider "aws" {
    profile    = "default"
    region     = var.region
}

output "_ci" {
  value = "ci"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "mgmthost" {
  ami                    = module.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
#   key_name               = "devops_admin_key2"
#   vpc_security_group_ids = [aws_security_group.mgmt_node.id]

  user_data = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt-get -y install awscli

        sudo apt-get -y install software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt-get -y install ansible
        EOF

  tags = {
    "role" : "MgmtHost"
  }
}
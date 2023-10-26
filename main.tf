terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
  }

}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_security_group" "CiscoLive-securityGroup" {
  name        = "MRE Cisco Live SecGroup"
  description = "Allow inbound CAPWAP Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "CAPWAP"
    from_port   = 5246
    to_port     = 5248
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "CAPWAP"
    from_port   = 5246
    to_port     = 5248
    protocol    = "tcp"
    cidr_blocks = [var.home_subnet_IP]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "SNMP"
    from_port   = 161
    to_port     = 162
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "MyHomeIP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.home_ip]
  }

  ingress {
    description = "TACAS+_TCP"
    from_port   = 49
    to_port     = 49
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "TACAS+_UDP"
    from_port   = 49
    to_port     = 49
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  egress {
    description = "TACAS+_UDP"
    from_port   = 49
    to_port     = 49
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "NTP"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "Syslog"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "RADIUS"
    from_port   = 1812
    to_port     = 1813
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "RADIUS"
    from_port   = 1645
    to_port     = 1645
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "RADIUS"
    from_port   = 1645
    to_port     = 1645
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "TDL"
    from_port   = 8004
    to_port     = 8004
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "SNMP"
    from_port   = 161
    to_port     = 161
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "netconf"
    from_port   = 830
    to_port     = 830
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "FastLocate"
    from_port   = 2003
    to_port     = 2003
    protocol    = "udp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "NMSP"
    from_port   = 16113
    to_port     = 16113
    protocol    = "tcp"
    cidr_blocks = [var.all_subnets]
  }

  ingress {
    description = "PING"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr_blocks]
  }

  ingress {
    description = "All Traffic from 10.0.43.0/24"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [var.home_subnet_IP]
  }

  ingress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [var.home_ip]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [var.all_subnets]
  }
}

resource "aws_security_group" "CiscoLive-ConnectorAllTraffic" {
  name        = "MRE Cisco Live ConenctorGroup"
  description = "Allow All Traffic to only Connector"
  vpc_id      = var.vpc_id

  ingress {
    description = "All Traffic from 10.0.43.0/24"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [var.all_subnets]
  }
}

resource "aws_instance" "CiscoLive-C9800-CL" {
  ami                         = var.c9800-ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  private_ip                  = var.c9800-staticIPv4
  vpc_security_group_ids      = [aws_security_group.CiscoLive-securityGroup.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  tags = {
    Name = "MRE_C9800-CL"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  user_data = file("9800.txt")
}


resource "aws_instance" "CiscoLive-SpacesConnector" {
  ami                    = var.SpacesConnector-ami
  instance_type          = var.instance_spaces_type
  subnet_id              = var.subnet_id
  private_ip             = var.ISE-staticIPv4
  vpc_security_group_ids = [aws_security_group.CiscoLive-securityGroup.id, aws_security_group.CiscoLive-ConnectorAllTraffic.id]
  key_name               = var.key_name
  associate_public_ip_address = true
  tags = {
    Name = "MRE_SpacesConnector"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }

}

/*
resource "aws_instance" "CiscoLive-ISE" {
  ami                         = var.ISE-ami
  instance_type               = var.ise_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.CiscoLive-securityGroup.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  tags = {
    Name = "MRE_ISE"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  user_data = file("ise.txt")
}

/*
resource "aws_instance" "CiscoLive-C8300" {
  ami                    = var.C8000-ami
  instance_type          = var.C8300_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.CiscoLive-securityGroup.id]
  associate_public_ip_address = true
  key_name               = var.key_name
  tags = {
    Name = "MRE_C8300"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  user_data = file("C8300.txt")
}
*/
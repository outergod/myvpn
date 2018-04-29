# MyVPN
# Copyright © 2018 Alexander Kahl <ak@sodosopa.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


## Locals
locals {
  bucket_name = "myvpn-${var.aws_region}.${var.domain}"
  availability_zone = "${var.aws_region}${var.aws_zone}"
}


## Provider
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}


## AMI
data "aws_ami" "fedora" {
  most_recent = true

  filter {
    name = "name"
    values = ["Fedora-Cloud-Base-*HVM-standard-0"]
  }

  owners = ["125523088429"]
}


## Default resources
data "aws_subnet" "default" {
  availability_zone = "${local.availability_zone}"
  default_for_az = true
}

data "aws_security_group" "default" {
  name = "default"
}


## Auth
resource "aws_key_pair" "auth" {
  key_name = "myvpn"
  public_key = "${var.public_key}"
}

resource "aws_iam_user" "myvpn" {
  name = "myvpn-${var.aws_region}"
}

resource "aws_iam_access_key" "myvpn" {
  user = "${aws_iam_user.myvpn.name}"
}


## Bucket
data "template_file" "bucket_policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    arn = "${aws_iam_user.myvpn.arn}"
    bucket = "${local.bucket_name}"
  }
}

resource "aws_s3_bucket" "myvpn" {
  bucket = "${local.bucket_name}"
  acl = "private"
  policy = "${data.template_file.bucket_policy.rendered}"

  tags {
    Name = "myvpn bucket for ${var.aws_region}"
  }
}


## OpenVPN Config
data "template_file" "server_conf" {
  template = "${file("${path.module}/server.conf")}"

  vars {
    ca = "${file("${path.module}/cert/ca.pem")}"
    key = "${file("${path.module}/cert/server.key")}"
    cert = "${file("${path.module}/cert/server.pem")}"
    tls_auth = "${file("${path.module}/cert/ta.key")}"
    dh = "${file("${path.module}/cert/dh.pem")}"
  }
}

data "template_file" "client_conf" {
  template = "${file("${path.module}/client.conf")}"

  vars {
    ip = "${aws_eip.ip.public_ip}"
    ca = "${file("${path.module}/cert/ca.pem")}"
    key = "${file("${path.module}/cert/client.key")}"
    cert = "${file("${path.module}/cert/client.pem")}"
    tls_auth = "${file("${path.module}/cert/ta.key")}"
    dh = "${file("${path.module}/cert/dh.pem")}"
  }
}

resource "local_file" "ovpn" {
  content = "${data.template_file.client_conf.rendered}"
  filename = "${path.module}/myvpn.ovpn"
}

resource "aws_s3_bucket_object" "server_conf" {
  bucket = "${aws_s3_bucket.myvpn.bucket}"
  key = "server.conf"
  content = "${data.template_file.server_conf.rendered}"
}


## Setup
data "template_file" "init" {
  template = "${file("${path.module}/init.yaml")}"

  vars {
    hostname = "${var.hostname}.${var.domain}"
    server_conf = "s3://${aws_s3_bucket.myvpn.bucket}/server.conf"
  }
}

data "template_file" "credentials" {
  template = "${file("${path.module}/credentials.sh")}"

  vars {
    access_key = "${aws_iam_access_key.myvpn.id}"
    secret_access_key = "${aws_iam_access_key.myvpn.secret}"
  }
}

data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.credentials.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.init.rendered}"
  }
}


## Security Group
resource "aws_security_group" "openvpn" {
  name        = "openvpn"
  description = "Allow OpenVPN access from anywhere"

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


## Instance
resource "aws_instance" "myvpn" {
  ami = "${data.aws_ami.fedora.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.auth.key_name}"
  user_data = "${data.template_cloudinit_config.config.rendered}"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}", "${aws_security_group.openvpn.id}"]
  subnet_id = "${data.aws_subnet.default.id}"

  tags {
    Name = "myvpn instance for ${var.aws_region}"
  }
}


## Elastic IP
resource "aws_eip" "ip" {
  instance = "${aws_instance.myvpn.id}"
}

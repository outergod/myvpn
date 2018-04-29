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

variable "aws_region" {
  description = "AWS region to launch server in."
  default = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use. There must be a corresponding profile section in the running user's AWS credentials file."
}

variable "aws_zone" {
  description = "Availability zone to use. Can usually be left alone."
  default = "a"
}

variable "domain" {
  description = "Domain name to use (can be completely fake). Used to make sure there is no overlap for the S3 bucket, so try to insert a unique value, no matter what."
}

variable "public_key" {
  description = "Public SSH key to deploy to all instances. Only required to connect to an instance directly after the VPN connection has been established."
}

variable "hostname" {
  description = "Hostname for the VPN host."
}

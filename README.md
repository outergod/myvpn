MyVPN
=====

MyVPN is a polyglot project to quickly set up personal, low-cost OpenVPN
instances in AWS. Is can be used for web services testing or to bypass region
restrictions on popular services - however, do so at your own risk!

MyVPN is based on [Terraform], [OpenVPN], [Fedora Cloud Base], 
[Amazon Web Services] and [GnuTLS].


Dependencies
------------

In order to set up MyVPN, the following tools need to be installed:
- [Terraform]
- [GnuTLS] Utils
- [OpenVPN]
- [GNU Make]

You also need a working account with [Amazon Web Services].

Once a MyVPN instance has been set up, only OpenVPN itself is needed to connect
to it.


Usage
-----

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and adapt to your
   needs. Please read `variables.tf` for an explanation of the fields.
2. Run `make` in the project directory. This will generate certificates and call
   `terraform apply` on your behalf. Confirm to apply all changes. Wait until
   terraform finishes.
3. Test the connection to the new instance using the generated `myvpn.ovpn`
   file: `openvpn myvpn.ovpn` (as root).
4. Deploy `myvpn.ovpn` so it can be used without hassle; this depends on the
   respective OS and wrapper in use.

Please keep in mind that **running MyVPN incurs costs**. Stop MyVPN EC2 instances
or destroy the AWS resources using `terraform destroy` and re-create them as
needed in order to save money!

`myvpn.ovpn` contains sensitive certificates and enables anyone with a copy of
the file to connect to MyVPN, so share at your discretion!


License
-------

Copyright © 2018 Alexander Kahl <ak@sodosopa.io>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.


[Terraform]: https://www.terraform.io/
[OpenVPN]: https://openvpn.net/index.php/open-source/overview.html
[Fedora Cloud Base]: https://alt.fedoraproject.org/cloud/
[Amazon Web Services]: https://aws.amazon.com/
[GnuTLS]: https://www.gnutls.org/
[GNU Make]: https://www.gnu.org/software/make/

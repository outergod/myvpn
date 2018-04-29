all: terraform

terraform: cert
	@terraform apply

cert:
	$(MAKE) -C $@

connect:
	@openvpn myvpn.ovpn

destroy:
	@terraform destroy

.PHONY: all terraform cert connect destroy

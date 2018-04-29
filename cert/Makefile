DEPS = openvpn certtool
KEYS = ca.key client.key server.key
CERTS = client.pem server.pem

all: $(DEPS) $(CERTS) dh.pem ta.key

$(DEPS):
	@which $@ > /dev/null 2>&1 || (echo "Please install $@"; exit 1)

ta.key:
	@openvpn --genkey --secret $@

dh.pem:
	@certtool --get-dh-params --outfile $@ --sec-param medium

$(KEYS):
	@certtool --generate-privkey --ecc --outfile $@

ca.pem: ca.key
	@certtool --generate-self-signed --load-privkey $< --template ca.conf --outfile $@

%.pem: %.key ca.pem
	@certtool --generate-certificate --load-privkey $< \
                  --load-ca-certificate ca.pem --load-ca-privkey ca.key \
                  --template $(patsubst %.pem,%.conf,$@) --outfile $@ 

.PHONY: all

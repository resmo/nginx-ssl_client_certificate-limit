.PHONY: create-ca
create-cakey:
	openssl genrsa -out ca.key 4096
	openssl genrsa -out ca1.key 4096
	openssl genrsa -out ca2.key 4096

.PHONY: create-cacert
create-cacert:
	openssl req -subj "/C=GB/CN=tls" -passin pass:$(pass) -new -x509 -days 365 -key ca.key -out ca.crt
	openssl req -subj "/C=GB/CN=ca1" -passin pass:$(pass) -new -x509 -days 365 -key ca1.key -out auth_ca1.crt
	openssl req -subj "/C=GB/CN=ca2" -passin pass:$(pass) -new -x509 -days 365 -key ca2.key -out auth_ca2.crt

.PHONY: create-clientcert1
create-clientcert1:
	openssl genrsa -out client1.key 4096
	openssl req -new -subj "/C=GB/CN=foo1" -passin pass:$(pass) -key client1.key -out client1.csr
	openssl x509 -req -days 365 -in client1.csr -CA auth_ca1.crt -CAkey ca1.key -set_serial 01 -out client1.crt

.PHONY: create-clientcert2
create-clientcert2:
	openssl genrsa -out client2.key 4096
	openssl req -new -subj "/C=GB/CN=foo2" -passin pass:$(pass) -key client2.key -out client2.csr
	openssl x509 -req -days 365 -in client2.csr -CA auth_ca2.crt -CAkey ca2.key -set_serial 01 -out client2.crt

.PHONY: certs
certs: create-cakey create-cacert create-clientcert1 create-clientcert2

.PHONY: docker
docker:
	docker build -t test .
	docker run --rm -p 8443:443 test

test:
	curl -H "Host: foo1.example.com" --insecure  https://127.0.0.1:8443/
	curl -H "Host: foo1.example.com" --insecure --cert ./client1.crt --key client1.key https://127.0.0.1:8443/
	curl -H "Host: foo1.example.com" --insecure --cert ./client2.crt --key client2.key https://127.0.0.1:8443/

	curl -H "Host: foo2.example.com" --insecure https://127.0.0.1:8443/
	curl -H "Host: foo2.example.com" --insecure --cert ./client2.crt --key client2.key https://127.0.0.1:8443/
	curl -H "Host: foo2.example.com" --insecure --cert ./client1.crt --key client1.key https://127.0.0.1:8443/

clean:
	git clean -fX

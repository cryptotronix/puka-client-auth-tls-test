#!/bin/bash

set -e

# making a directory to keep our mess contained
cd ./puca-certs
mkdir -p temp-work
cd temp-work
export PUCA_CWD=`pwd`
mkdir -p certs crl newcerts private
touch index.txt
echo 1000 > serial

# generating root CA
echo "generating root ca..."
openssl ecparam \
	-name prime256v1 \
	-genkey \
	-noout \
	-out private/root.key.pem
openssl req \
	-config ../configs/root.conf \
	-key private/root.key.pem \
	-new \
	-nodes \
	-x509 \
	-days 365 \
	-sha256 \
	-extensions v3_ca \
      	-out certs/root-ca.crt.pem \
	-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puca Training Root CA"

# generating intermediate CA
mkdir -p intermediate
cd intermediate
mkdir -p certs crl newcerts private csr
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
echo "generating intermediate TLS ca..."
cd ..
openssl ecparam \
	-name prime256v1 \
	-genkey \
	-noout \
	-out intermediate/private/intermediate.key.pem
openssl req \
	-config ../configs/intermediate.conf \
	-new \
	-sha256 \
	-key intermediate/private/intermediate.key.pem \
	-out intermediate/csr/intermediate.csr.pem \
	-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puca Training TLS CA"
openssl ca \
	-config ../configs/root.conf \
	-extensions v3_intermediate_ca \
	-days 365 \
	-batch \
	-notext \
	-md sha256 \
	-in intermediate/csr/intermediate.csr.pem \
	-out intermediate/certs/intermediate-ca.crt.pem

# generating server cert
echo "generating server cert..."
openssl ecparam \
	-name prime256v1 \
	-genkey \
	-noout \
	-out intermediate/private/server.key.pem
openssl req \
	-config ../configs/intermediate.conf \
	-new \
	-sha256 \
	-key intermediate/private/server.key.pem \
	-out intermediate/csr/server.csr.pem \
	-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puca Training Server"
openssl ca \
	-config ../configs/intermediate.conf \
	-extensions server_cert \
	-days 365 \
	-batch \
	-notext \
	-md sha256 \
	-in intermediate/csr/server.csr.pem \
	-out intermediate/certs/server.crt.pem

# generating client cert
echo "generating client cert..."
openssl ecparam \
	-name prime256v1 \
	-genkey \
	-noout \
	-out intermediate/private/client.key.pem
openssl req \
	-config ../configs/intermediate.conf \
	-new \
	-sha256 \
	-key intermediate/private/client.key.pem \
	-out intermediate/csr/client.csr.pem \
	-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puca Training Client"
#openssl req \
#	-new \
#	-sha256 \
#	-engine see_engine \
#	-keyform ENGINE \
#	-key 1 \
#	-out intermediate/csr/client.csr.pem \
#	-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puca Training Client"
openssl ca \
	-config ../configs/intermediate.conf \
	-extensions usr_cert \
	-days 365 \
	-batch \
	-notext \
	-md sha256 \
	-in intermediate/csr/client.csr.pem \
	-out intermediate/certs/client.crt.pem

echo "writing certs and keys in puca-certs..."
# make root ca + key file
cat certs/root-ca.crt.pem \
      private/root.key.pem > ../puca-root-ca.crt.key.pem

# make tls ca + key file
cat intermediate/certs/intermediate-ca.crt.pem \
      intermediate/private/intermediate.key.pem > ../puca-tls-ca.crt.key.pem

# make ca chain file
cat intermediate/certs/intermediate-ca.crt.pem \
      certs/root-ca.crt.pem > ../puca-ca-chain.crt.pem

# make server cert + key file
cat intermediate/certs/server.crt.pem \
      intermediate/private/server.key.pem > ../puca-server.crt.key.pem

# make client cert + key file
cat intermediate/certs/client.crt.pem \
      intermediate/private/client.key.pem > ../puca-client.crt.key.pem

echo "removing artifacts..."
cd ..
rm -rf temp-work
echo "done!"

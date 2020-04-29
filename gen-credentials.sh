#!/bin/bash

all=0
init=0
csr=
name=

# print the usage of this script
print_usage() {
  printf "Usage: gen-credentials.sh [OPTION]\n"
  printf "Generate a set of credentials auto-magically, or specify stages and sources for specific use.\n\n"
  printf "  %s\t\tspecify an absolute path to a CSR file for the intermediate CA to sign\n\n" '-r'
  printf "  %s\t\toptionally specify a name for the resulting cert generated by providing the -r flag\n\n" '-n'
  printf "  %s\t\tautomatically generate a root CA, intermediate CA, server cert, and client cert (default if no flags provided)\n\n" '-a'
  printf "  %s\t\tgenerate only the initial root CA and the intermediate CA\n\n" '-i'
  echo -e "Examples:\n"
  echo -e "sh gen-credentials -r /home/example.csr -n example.cert.pem"
  echo -e "\n\t signs example.csr and puts the resulting cert named example.cert.pem in puca-certs\n"
  echo -e "sh gen-credentials -r /home/example.csr"
  echo -e "\n\t signs example.csr but uses default name cert.pem for the resulting cert\n"
  echo -e "sh gen-credentials -i"
  echo -e "\n\t generates only the CAs in puca-certs\n"
  echo -e "sh gen-credentials -a"
  echo -e "\n\tGenerates the following in puca-certs:\n"
  echo -e "\tpuca-root-ca.cert.key.pem: a root ca and its respective private key"
  echo -e "\tpuca-tls-ca.cert.key.pem: a tls ca and its respective private key"
  echo -e "\tpuca-ca-chain.cert..pem: the root ca and the tls ca WITHOUT their keys"
  echo -e "\tpuca-server.cert.key.pem: a server cert and its respective private key"
  echo -e "\tpuca-client.cert.key.pem: a client cert and its respective private key\n"
  echo -e "sh gen-credentials"
  echo -e "\n\t same behaviour as -a\n"
}

init() {
	mkdir -p certs crl newcerts private
	touch index.txt index.txt.attr
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
	      	-out certs/root-ca.cert.pem \
		-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puca Training Root CA"

	# generating intermediate CA
	mkdir -p intermediate
	cd intermediate
	mkdir -p certs crl newcerts private csr
	touch index.txt index.txt.attr
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
		-out intermediate/certs/intermediate-ca.cert.pem
	# make root ca + key file
	cat certs/root-ca.cert.pem \
	      private/root.key.pem > ../puca-root-ca.cert.key.pem

	# make tls ca + key file
	cat intermediate/certs/intermediate-ca.cert.pem \
	      intermediate/private/intermediate.key.pem > ../puca-tls-ca.cert.key.pem

	# make ca chain file
	cat intermediate/certs/intermediate-ca.cert.pem \
	      certs/root-ca.cert.pem > ../puca-ca-chain.cert.pem
}

certs() {
	if [ -f ../puca-tls-ca.cert.key.pem ]; then
		mkdir -p intermediate
		cd intermediate
		mkdir -p certs crl newcerts private csr
		touch index.txt index.txt.attr
		echo 1000 > serial
		echo 1000 > crlnumber
		cd ..
		cp ../puca-tls-ca.cert.key.pem intermediate/certs/intermediate-ca.cert.pem
		cp ../puca-tls-ca.cert.key.pem intermediate/private/intermediate.key.pem
	else
		init
	fi

	if [ ! -z "$csr" ] && [ $all -eq 0 ]; then
		if [ -z "$name" ]; then
			echo "using default cert name cert.pem..."
			name="cert.pem"
		fi
		echo "generating cert..."

		openssl ca \
			-config ../configs/intermediate.conf \
			-extensions server_cert \
			-days 365 \
			-batch \
			-notext \
			-md sha256 \
			-in $csr \
			-out intermediate/certs/$name
		cp intermediate/certs/$name ../$name
	else
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
			-out intermediate/certs/server.cert.pem

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
			-out intermediate/certs/client.cert.pem

		# make server cert + key file
		cat intermediate/certs/server.cert.pem \
		      intermediate/private/server.key.pem > ../puca-server.cert.key.pem

		# make client cert + key file
		cat intermediate/certs/client.cert.pem \
		      intermediate/private/client.key.pem > ../puca-client.cert.key.pem
	fi
}


# Parsing option flags
while getopts 'air:n:' flag; do
  case "${flag}" in
    a) all=1 ;;
    i) init=1 ;;
    r) csr="${OPTARG}" ;;
    n) name="${OPTARG}" ;;
    h) print_usage
       exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done
# input error handling
if [ $all -eq 0 ] && [ $init -eq 0 ] && [ -z "$csr" ] && [ -z "$name" ]; then
	all=1
fi

if [ ! -z "$name" ] && [ -z "$csr" ]; then
	echo "error! -n requires that -r is also specified "
	exit 1
fi


# making a directory to keep our mess contained
cd ./puca-certs
mkdir -p temp-work

# exit and delete dir if any command fails
trap 'echo "removing artifacts..."; cd ..; rm -rf temp-work; echo -e "done.\nfailed!"; exit 1' ERR


# enter our work directory
cd temp-work
export PUCA_CWD=`pwd`


if [ $all -eq 1 ]; then
	init
	certs
elif [ $init -eq 1 ]; then
	init
elif [ ! -z "$csr" ]; then
	certs
fi

echo "removing artifacts..."
cd ..
rm -rf temp-work
echo "done."
echo "success!"

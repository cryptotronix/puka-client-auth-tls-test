#!/bin/bash

EXECDIR=
TMPDIR=
config_dir=

# print the usage of this script
print_usage() {
  printf "\nUsage: init-puka-pki.sh CONFIGS_DIR\n"
  printf "\nInitialize the puka pki using the CONFIGS_DIR specified. Should be run in the same directory as CONFGIS_DIR\n\n"
  echo -e "Example:\n"
  echo -e "./init-puka-pki.sh configs"
  echo -e "\n\tGenerates the following in your current directory:\n"
  echo -e "\tpuka-root-ca.cert.key.pem: a root ca and its respective private key"
  echo -e "\tpuka-tls-ca.cert.key.pem: an intermediate ca and its respective private key"
  echo -e "\tpuka-ca-chain.cert..pem: the root ca and the tls ca WITHOUT their keys"
  echo -e "\tpuka-server.cert.key.pem: a server cert and its respective private key"
  echo -e "\tpuka-client.cert.key.pem: a client cert and its respective private key\n"
}

init() {
	# prep to make root ca
	cd $TMPDIR
	mkdir -p certs crl newcerts private
	touch index.txt index.txt.attr
	echo 1000 > serial
	cd $EXECDIR

	# generating root CA
	echo "generating root ca..."
	openssl ecparam \
		-name prime256v1 \
		-genkey \
		-noout \
		-out $TMPDIR/private/root.key.pem
	openssl req \
		-config $configs_dir/root.conf \
		-key $TMPDIR/private/root.key.pem \
		-new \
		-nodes \
		-x509 \
		-days 365 \
		-sha256 \
		-extensions v3_ca \
	      	-out $TMPDIR/certs/root-ca.cert.pem \
		-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puka Training Root CA"

	# prep to make intermediate ca
	cd $TMPDIR
	cd $TMPDIR
	mkdir -p intermediate
	cd intermediate
	mkdir -p certs crl newcerts private csr
	touch index.txt index.txt.attr
	echo 1000 > serial
	echo 1000 > crlnumber
	cd $EXECDIR

	# generating intermediate CA
	echo "generating intermediate TLS ca..."
	cd ..
	openssl ecparam \
		-name prime256v1 \
		-genkey \
		-noout \
		-out $TMPDIR/intermediate/private/intermediate.key.pem
	openssl req \
		-config $configs_dir/intermediate.conf \
		-new \
		-sha256 \
		-key $TMPDIR/intermediate/private/intermediate.key.pem \
		-out $TMPDIR/intermediate/csr/intermediate.csr.pem \
		-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puka Training TLS CA"
	openssl ca \
		-config $configs_dir/root.conf \
		-extensions v3_intermediate_ca \
		-days 365 \
		-batch \
		-notext \
		-md sha256 \
		-in $TMPDIR/intermediate/csr/intermediate.csr.pem \
		-out $TMPDIR/intermediate/certs/intermediate-ca.cert.pem

	# generating server cert
	echo "generating server cert..."
	openssl ecparam \
		-name prime256v1 \
		-genkey \
		-noout \
		-out $TMPDIR/intermediate/private/server.key.pem
	openssl req \
		-config $configs_dir/intermediate.conf \
		-new \
		-sha256 \
		-key $TMPDIR/intermediate/private/server.key.pem \
		-out $TMPDIR/intermediate/csr/server.csr.pem \
		-subj "/C=AU/ST=Some-State/O=Internet Widgets Pty Ltd/CN=Puka Training Server"
	openssl ca \
		-config $configs_dir/intermediate.conf \
		-extensions server_cert \
		-days 365 \
		-batch \
		-notext \
		-md sha256 \
		-in $TMPDIR/intermediate/csr/server.csr.pem \
		-out $TMPDIR/intermediate/certs/server.cert.pem

	# make root ca + key file
	cat $TMPDIR/certs/root-ca.cert.pem \
	      $TMPDIR/private/root.key.pem > $EXECDIR/puka-root-ca.cert.key.pem

	# make tls ca + key file
	cat $TMPDIR/intermediate/certs/intermediate-ca.cert.pem \
	      $TMPDIR/intermediate/private/intermediate.key.pem > $EXECDIR/puka-tls-ca.cert.key.pem

	# make ca chain file
	cat $TMPDIR/intermediate/certs/intermediate-ca.cert.pem \
	      $TMPDIR/certs/root-ca.cert.pem > $EXECDIR/puka-ca-chain.cert.pem

	# make server cert + key file
	cat $TMPDIR/intermediate/certs/server.cert.pem \
	      $TMPDIR/intermediate/private/server.key.pem > $EXECDIR/puka-server.cert.key.pem
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	print_usage
	exit 0
fi
if [ $# -ne 1 ]; then
	print_usage
	exit 1
fi

configs_dir=`realpath $1`

# input verification
if [ ! -d $configs_dir ]; then
	>&2 echo "error: $configs_dir does not exist"
	exit 1
else
	if [ ! -r $configs_dir/root.conf ]; then
		>&2 echo "error: $configs_dir missing root.conf"
		exit 1
	fi
	if [ ! -r $configs_dir/intermediate.conf ]; then
		>&2 echo "error: $configs_dir missing intermediate.conf"
		exit 1
	fi
fi

EXECDIR=`pwd`

# making a directory to keep our mess contained
TMPDIR=`mktemp -d`

if [ ! -e $TMPDIR ]; then
    >&2 echo "error: could not create temp dir"
    exit 1
fi

# exit and delete dir if any command fails
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'exit "$?"'        ERR
trap 'rm -rf "$TMPDIR"' EXIT

# enter our work directory
export PUKA_CWD=$TMPDIR

init

echo -e "\nsuccess!"

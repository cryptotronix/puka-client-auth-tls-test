#!/bin/bash

EXECDIR=
TMPDIR=
pkidir=
csr=

# print the usage of this script
print_usage() {
  printf "\nUsage: create_client_cert.sh CSR PKI_DIR\n"
  printf "\nSign the provided CSR to create a client cert using the puka pki at PKI_DIR.\n\n"
  echo -e "Example:\n"
  echo -e "./create_client_cert.sh /home/example.csr puka-certs/"
  echo -e "\n\t signs example.csr to create client.cert.pem in your current directory\n"
}

sign() {
	# structure for using ca, will be deleted after signature
	mkdir -p $TMPDIR/intermediate
	cd $TMPDIR/intermediate
	mkdir -p certs crl newcerts private csr
	touch index.txt index.txt.attr
	echo 1000 > serial
	echo 1000 > crlnumber
	cd $EXECDIR

	cp $pkidir/puka-tls-ca.cert.key.pem $TMPDIR/intermediate/certs/intermediate-ca.cert.pem
	cp $pkidir/puka-tls-ca.cert.key.pem $TMPDIR/intermediate/private/intermediate.key.pem

	echo "generating cert..."

	openssl ca \
		-config ${pkidir}/configs/intermediate.conf \
		-days 365 \
		-batch \
		-notext \
		-md sha256 \
		-in $csr \
		-out $TMPDIR/intermediate/certs/client.cert.pem
	#move the cert to the top level
	cp $TMPDIR/intermediate/certs/client.cert.pem $EXECDIR/client.cert.pem
}

# usage captures

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	print_usage
	exit 0
fi
if [ $# -ne 2 ]; then
	print_usage
	exit 1
fi

csr=`realpath $1`
pkidir=`realpath $2`

# input verification

if [ ! -f $csr ]; then
	>&2 echo "error: $csr does not exist"
	exit 1
elif [ ! -r $csr ]; then
	>&2 echo "error: cannot read $csr"
	exit 1
fi

if [ ! -d $pkidir ]; then
	>&2 echo "error: $pkidir does not exist"
	exit 1
else
	if [ ! -r $pkidir/puka-tls-ca.cert.key.pem ]; then
		>&2 echo "error: $pkidir does not contain initialized puka pki"
		exit 1
	fi
	if [ ! -d $pkidir/configs ]; then
		>&2 echo "error: $pkidir does not contain necessary configs directory"
		exit 1
	fi
fi

#execution

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

# perform the sign
sign
echo -e "\nsuccess!"

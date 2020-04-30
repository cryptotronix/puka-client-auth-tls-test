#!/bin/bash

# print the usage of this script
print_usage() {
  printf "\nUsage: test-tls-connection.sh CLIENT_CERT CA_FILE \n"
  printf "\nUses s_client to connect to https://localhost:8433 with a"
  printf "\nCLIENT CERT made by the puka engine and the CA_FILE.\n\n"
  echo -e "Example:\n"
  echo -e "./test-tls-connection.sh client.cert.pem puka-certs/puka-ca-chain.cert.key.pem\n"
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

cert=`realpath $1`
ca=`realpath $2`

# input verification

if [ ! -f $cert ]; then
	>&2 echo "error: $csr does not exist"
	exit 1
elif [ ! -r $cert ]; then
	>&2 echo "error: cannot read $csr"
	exit 1
fi
if [ ! -f $ca ]; then
	>&2 echo "error: $csr does not exist"
	exit 1
elif [ ! -r $ca ]; then
	>&2 echo "error: cannot read $csr"
	exit 1
fi

echo -e "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n" | openssl s_client -tls1_2 -ign_eof -connect localhost:8443 -CAfile $ca -certform PEM -cert $cert -key 1 -keyform ENGINE -engine puka-engine

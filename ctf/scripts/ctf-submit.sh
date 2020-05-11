#!/bin/bash

# print the usage of this script
print_usage() {
  printf "\nUsage: ctf-check.sh CA_CERT CLIENT_CERT BASE_URI SUBMISSION\n"
  printf "\nSubmit an answer to the ctf server. Save the response uuid.\n\n"
  echo -e "\tCA_CERT: the path to the puka ca chain"
  echo -e "\tCLIENT_CERT: the path to your generated client cert and key in the same file"
  echo -e "\tBASE_URI: provide the location of the server"
  echo -e "\tSUBMISSION: your base64 encoded submission\n"
  echo -e "Example:\n"
  echo -e "./ctf-submit.sh puka-certs/puka-ca-chain.cert.pem client.cert.pem https://example.uri ZXhhbXBsZQ=="
}

# usage captures

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	print_usage
	exit 0
fi
if [ $# -ne 4 ]; then
	print_usage
	exit 1
fi

ca=`realpath $1`
client=`realpath $2`
base_uri=$3
submission=$4

# input verification

if [ ! -f $ca ]; then
	>&2 echo "error: $ca does not exist"
	exit 1
elif [ ! -r $ca ]; then
	>&2 echo "error: cannot read $ca"
	exit 1
fi

if [ ! -f $client ]; then
	>&2 echo "error: $client does not exist"
	exit 1
elif [ ! -r $client ]; then
	>&2 echo "error: cannot read $client"
	exit 1
fi

#execution

curl \
	-v \
	--cacert $ca \
	--cert $client \
	--tlsv1.2 \
	-d"$submission" \
	-H"Content-Type: text/plain" \
	$base_uri/submit

if [ $? -eq 58 ]; then
	echo -e "\nEnsure that your client cert file also contains the private key. "
fi

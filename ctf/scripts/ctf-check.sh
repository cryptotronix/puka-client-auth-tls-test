#!/bin/bash

# print the usage of this script
print_usage() {
  printf "\nUsage: ctf-check.sh CA_CERT CLIENT_CERT BASE_URI UUID\n"
  printf "\nCheck the results of a submission to the ctf server.\n\n"
  echo -e "\tCA_CERT: the path to the puka ca chain"
  echo -e "\tCLIENT_CERT: the path to your generated client cert and key in the same file"
  echo -e "\tBASE_URI: provide the location of the server"
  echo -e "\tUUID: the uuid you recieved as the response to your submission\n"
  echo -e "Example:\n"
  echo -e "./ctf-check.sh puka-certs/puka-ca-chain.cert.pem client.cert.pem https://example.uri 8a2dc89c-12e5-4dfb-b72b-e930d4782ce6"
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
uuid=$4

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
	$base_uri/check\?uuid\=$uuid

curlrc=$?
if [ $curlrc -eq 58 ]; then
	echo -e "\nEnsure that your client cert file also contains the private key ($ cat client.key.pem >> client.cert.pem)."
else
	exit $curlrc
fi

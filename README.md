# puka-training-endpoint
A training NGINX endpoint with client and server verification.

## Server Usage

To start the server, run `./start_server.sh`. To free the terminal, use `^C`.

Once running, simple static html page with client verification should now be available at `https://localhost:8443`.

## Client Cert Generation

To generate a client cert from a valid CSR, run `./create-client-cert.sh [FILENAME OF YOUR CSR] [PKI DIRECTORY PATH]`. In this case `PKI DIRECTORY` is `puka-certs/`.

If successful, you'll find `client-cert.pem` in your current directory.

## Accessing the server using s\_client



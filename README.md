# puka-training-endpoint
A training NGINX endpoint with client and server verification.

## Server Usage

To start the server, run `./start_server.sh`. To free the terminal, use `^C`.

Once running, simple static html page with client verification should now be available at `https://localhost:8443`.

## Client Cert Generation

To generate a client cert from a valid CSR, run:
```
./create-client-cert.sh [FILENAME OF YOUR CSR] [PKI DIRECTORY PATH]
```
In this case `[PKI DIRECTORY PATH]` is `puka-certs/` if you are in the repo root.

Upon success, you'll find `client.cert.pem` in your current directory.

## Accessing the server using s\_client

We have provided a script for easy usage of a long s\_client one-liner:

```
./test-tls-connection.sh [CLIENT CERT] [CA CHAIN]
```

`[CLIENT CERT]` is your generated `client.cert.pem`. Note, the CSR that created this cert must have been made using the puka engine.

`[CA CHAIN]` are the certs contained in `puka-certs/puka-ca-chain.cert.pem`.

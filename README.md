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

Upon success, you'll find `client-cert.pem` in your current directory.

## Accessing the server using s\_client

The format for a basic request is as follows:

```
echo -e "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n" | openssl s_client -tls1_2 -ign_eof -connect localhost:8443 -CAfile [CA CHAIN] -certform PEM -cert [CLIENT CERT] -key [CLIENT KEY] -keyform [FORM]
```

`[CA CHAIN]` are the certs contained in `puka-certs/puka-ca-chain.cert.pem`.

`[CLIENT CERT]` is your generated `client-cert.pem`.

`[CLIENT KEY]` is `1`.

`[FORM]` is `ENGINE` as we are using the puka engine.

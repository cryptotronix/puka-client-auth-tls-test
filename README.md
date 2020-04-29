# puca-training-endpoint
A training NGINX endpoint with client and server verification.

## Server Usage

To pull the pre-built image from dockerhub, run `$ docker pull cryptotronix/puca-nginx:latest`.

To run the image in-terminal: `$ docker run -p 8080:80 puca-nginx`

If you want to run the image detached from the terminal, add the -d flag and -name so it can be easily stopped: `$ docker run -name puca-nginx -d -p 8080:80 puca-nginx`

Once running, simple static html page with client verification should now be available at `https://localhost:8080`.

If you want to build your image locally, make sure you have first run `bash gen-credentials.sh`. Check to make sure both `puca-ca-chain.cert.pem` and `puca-server.cert.key.pem` are in `puca-certs/`, then run `docker build -t puca-nginx .` from the repo root.

## Cert Generation

We have provided a script `gen-credentials.sh` that allows for manual creation of CAs and server/client certs with their respective private keys.

To sign a CSR, run `bash gen-credentials.sh -r [ABS PATH TO CSR] -n [DESIRED FILENAME FOR CERT]`. This will create a root CA and an intermediate CA for you first (if this hasn't already been done), and use the intermediate cert to sign your CSR. The signed cert with the desired filename will be placed in `puca-certs/`.

For more information on `gen-credentials.sh`, access the usage with `bash gen-credentials -h`.

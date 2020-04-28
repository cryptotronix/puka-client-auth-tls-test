# see-training-endpoint
A training NGINX endpoint with client and server verification.

## Usage

To build the docker image from scratch, run `$ docker build -t see-training-endpoint .` from repo root.

To pull the pre-built image from dockerhub, run `$ docker pull cryptotronix/see-training-endpoint:latest`.

To run the image: `$ docker run -name see -p 8080:80 see-training-endpoint`

Once running, simple static html page with client verification should now be available at `https://localhost:8080`.

## Cert Generation

We have provided a script `gen-credentials.sh` that allows for manual creation of a root CA, an intermediate TLS CA, a server cert, and a client cert with their respective private keys.


`bash gen-credentials.sh` will run the script, but make sure you are in the root direcotry of the repo or the script will fail. It should produce 5 files in `puca_certs`:

- `puca-root-ca.crt.key.pem`: the root ca and its respective private key 
- `puca-tls-ca.crt.key.pem`: the tls ca and its respective private key 
- `puca-ca-chain.crt.pem`: the root ca and the tls ca WITHOUT their keys
- `puca-server.crt.key.pem`: the server cert and its respective private key 
- `puca-client.crt.key.pem`: the client cert and its respective private key 

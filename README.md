# see-training-endpoint
A training NGINX endpoint with client and server verification.

## Usage

To build the docker image from scratch, run `$ docker build -t see-training-endpoint .` from repo root.

To pull the pre-built image from dockerhub, run `$ docker pull cryptotronix/see-training-endpoint:latest`.

To run the image: `$ docker run -name see -p 8080:80 see-training-endpoint`

Once running, simple static html page with client verification should now be available at `https://localhost:8080`.

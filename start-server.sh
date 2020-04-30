#!/bin/bash

docker pull cryptotronix/puca-nginx:latest
docker run -p 8443:443 cryptotronix/puca-nginx

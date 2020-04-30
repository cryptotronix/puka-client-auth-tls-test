#!/bin/bash

echo "pulling image..."
docker pull cryptotronix/puca-nginx:latest
echo "starting server..."
docker run -p 8443:443 cryptotronix/puca-nginx
echo -e "\ndone."

#!/bin/bash

echo "pulling image..."
docker pull cryptotronix/puka-nginx:latest
echo "starting server..."
docker run -p 8443:443 cryptotronix/puka-nginx
echo -e "\ndone."

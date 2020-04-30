#!/bin/bash

echo "pulling image..."
docker pull cryptotronix/puka-client-auth-tls-test:nginx-server
echo "starting server..."
docker run -p 8443:443 cryptotronix/puka-client-auth-tls-test:nginx-server
echo -e "\ndone."

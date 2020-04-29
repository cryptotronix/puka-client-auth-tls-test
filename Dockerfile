FROM nginx

EXPOSE 80

COPY docker/html /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY puca-certs /opt/certs

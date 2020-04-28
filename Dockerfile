FROM nginx

EXPOSE 80

COPY html /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
COPY puca-certs /opt/certs

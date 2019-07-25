#!/bin/sh
set -e

# Script adapted from:
# https://myopswork.com/how-to-do-end-to-end-encryption-of-data-in-transit-b-w-aws-alb-and-ec2-3b7fd917cddd
# AND
# https://medium.com/@oliver.zampieri/self-signed-ssl-reverse-proxy-with-docker-dbfc78c05b41

echo "Generating SSL for $DOMAIN"

openssl version

mkdir -p /etc/ssl/private
chmod 700 /etc/ssl/private
cd /etc/ssl/private

echo "Generating key request for $DOMAIN"
openssl req -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$DOMAIN/emailAddress=$EMAIL_ADDRESS" \
  -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365

echo "Using proxy address of $PROXY_ADDRESS"

cat <<EOF > /etc/nginx/nginx.conf
worker_processes 4;
 
events { worker_connections 1024; }
 
http {
    sendfile on;

    upstream app_servers {
        server $PROXY_ADDRESS:80;
    }

    server {
        listen 443;

        server_name localhost;

        ssl    on;
        ssl_certificate /etc/ssl/private/cert.pem;
        ssl_certificate_key /etc/ssl/private/key.pem;

        location / {
            proxy_pass         http://$PROXY_ADDRESS:80;
            proxy_http_version 1.1;

            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection keep-alive;
            proxy_set_header Host \$host;
            
            proxy_buffer_size       128k;
            proxy_buffers           4 256k;
            proxy_busy_buffers_size 256k;
        }
    }
}
EOF

# Start nginx
nginx -g 'daemon off;'
#!/bin/bash
set -euo pipefail
CERT_DIR=/etc/ssl
CRT_PATH=$CERT_DIR/certs/tls.crt
KEY_PATH=$CERT_DIR/private/tls.key
DOMAIN=${DOMAIN_NAME:-localhost}

mkdir -p $(dirname "$CRT_PATH") $(dirname "$KEY_PATH")

if [ ! -s "$CRT_PATH" ] || [ ! -s "$KEY_PATH" ]; then
  echo "[nginx-entrypoint] Generating self-signed certificate for $DOMAIN"
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -subj "/CN=$DOMAIN" \
    -addext "subjectAltName=DNS:$DOMAIN" \
    -keyout "$KEY_PATH" -out "$CRT_PATH" >/dev/null 2>&1
  chmod 600 "$KEY_PATH"
fi

# Update nginx.conf with the domain name
sed -i "s/server_name.*;/server_name $DOMAIN;/" /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'

#!/bin/bash
set -e

# WordPress salts の初期化（初回のみ）
if grep -q "put your unique phrase here" /var/www/html/wp-config.php; then
  for k in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
    R=$(openssl rand -base64 48 | tr -d "\n")
    sed -i "s/put your unique phrase here/${R}/" /var/www/html/wp-config.php
  done
fi

# php-fpmを起動
exec php-fpm -F

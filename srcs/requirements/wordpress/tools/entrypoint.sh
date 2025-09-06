#!/bin/bash
set -e

# MariaDBが起動するまで待機
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    sleep 1
done
echo "MariaDB is ready!"

# データベース接続をテスト（MariaDBでDBとユーザーは既に作成済み）
echo "Testing database connection..."
mysql -h"mariadb" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -D"${MYSQL_DATABASE}" \
  -e "SELECT 1;" >/dev/null 2>&1 || {
    echo "Error: Cannot connect to database ${MYSQL_DATABASE} with user ${MYSQL_USER}"
    exit 1
  }
echo "Database connection successful!"

# WordPress salts の初期化（初回のみ）
if grep -q "put your unique phrase here" /var/www/html/wp-config.php; then
  for k in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
    R=$(openssl rand -base64 48 | tr -d "\n")
    sed -i "s/put your unique phrase here/${R}/" /var/www/html/wp-config.php
  done
fi

# WordPressの初期化チェック（wp_options テーブルが存在し、データがあるかどうか）
cd /var/www/html

# WordPressがインストールされているかWP-CLIで確認
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    echo "Installing WordPress..."
    
    # WP-CLIでWordPressをインストール
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    
    echo "WordPress installation completed!"
    
    # 2番目のユーザーを作成（エディター権限）
    wp user create ${WP_EDITOR_USER} ${WP_EDITOR_EMAIL} \
        --role=editor \
        --user_pass="${WP_EDITOR_PASSWORD}" \
        --allow-root
    
    echo "Created editor user: ${WP_EDITOR_USER}"
    
    # ユーザー一覧を確認
    echo "WordPress users:"
    wp user list --allow-root
    
    echo "WordPress setup completed!"
else
    echo "WordPress is already initialized."
    
    # 既存のユーザー一覧を表示
    echo "Current WordPress users:"
    cd /var/www/html
    wp user list --allow-root || echo "Failed to list users"
fi

# php-fpm7.4を起動
exec php-fpm7.4 -F

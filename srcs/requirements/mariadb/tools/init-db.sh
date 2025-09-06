#!/bin/bash
set -e

SOCKET=""
if [[ "$1" == --socket=* ]]; then
  SOCKET="--socket=${1#--socket=}"
fi

# Passwords only from environment now
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD not set}" 
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD not set}"

MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}
# WordPress 用ユーザー
MYSQL_USER=${MYSQL_USER:-wp_user}
# 管理者 (admin, administrator など禁止) 例: siteowner
MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:-siteowner}
MYSQL_ADMIN_PASSWORD=${MYSQL_ADMIN_PASSWORD:-$(openssl rand -base64 24)}

# MySQL 起動は entrypoint 側

# まずパスワードなしで接続を試し、失敗したら既にパスワードが設定されているとみなす
if mysql $SOCKET -e "SELECT 1;" >/dev/null 2>&1; then
    echo "Root password not set yet, setting it now..."
    mysql $SOCKET -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    ROOT_CMD="mysql $SOCKET -u root -p${MYSQL_ROOT_PASSWORD}"
else
    echo "Root password already set, using existing password..."
    ROOT_CMD="mysql $SOCKET -u root -p${MYSQL_ROOT_PASSWORD}"
fi

echo "Creating database and users..."
$ROOT_CMD -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
$ROOT_CMD -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
$ROOT_CMD -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"

# 管理者ユーザー (WordPress 内では wp-admin で別途権限付与する想定)
$ROOT_CMD -e "CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';" || true

# Hardening (mysql_secure_installation 相当)
$ROOT_CMD -e "DELETE FROM mysql.user WHERE user='';" || true
$ROOT_CMD -e "DROP DATABASE IF EXISTS test;" || true
$ROOT_CMD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" || true

$ROOT_CMD -e "FLUSH PRIVILEGES;"

echo "Database initialization completed successfully!"


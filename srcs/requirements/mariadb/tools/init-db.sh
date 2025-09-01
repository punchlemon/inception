#!/bin/bash
set -e

SOCKET=""
if [[ "$1" == --socket=* ]]; then
  SOCKET="--socket=${1#--socket=}"
fi

# 環境変数または secrets からパスワード取得
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}
# WordPress 用ユーザー
MYSQL_USER=${MYSQL_USER:-wp_user}
# 管理者 (admin, administrator など禁止) 例: siteowner
MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:-siteowner}
MYSQL_ADMIN_PASSWORD=${MYSQL_ADMIN_PASSWORD:-$(openssl rand -base64 24)}

# MySQL 起動は entrypoint 側

mysql $SOCKET -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" || true

mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"

# 管理者ユーザー (WordPress 内では wp-admin で別途権限付与する想定)
mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';" || true

# Hardening (mysql_secure_installation 相当)
mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE user='';"
mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DROP DATABASE IF EXISTS test;"
mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" || true

mysql $SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"


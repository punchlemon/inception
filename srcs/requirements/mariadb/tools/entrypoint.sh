#!/bin/bash
set -euo pipefail
DATADIR=/var/lib/mysql
SOCKET=/var/run/mysqld/mysqld.sock

if [ ! -d "$DATADIR/mysql" ]; then
  echo "[entrypoint] initializing datadir"
  chown -R mysql:mysql "$DATADIR"
  mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal > /dev/null
  echo "[entrypoint] temporary server start"
  mysqld --skip-networking --socket=$SOCKET &
  pid=$!
  for i in {30..0}; do
    mysqladmin --socket=$SOCKET ping &>/dev/null && break
    sleep 1
  done
  if ! mysqladmin --socket=$SOCKET ping &>/dev/null; then
    echo "[entrypoint] temp mysqld failed" >&2; exit 1; fi
  /usr/local/bin/init-db.sh --socket=$SOCKET
  mysqladmin --socket=$SOCKET shutdown || true
  wait $pid || true
  echo "[entrypoint] initialization done"
fi

# 通常起動
exec mysqld_safe

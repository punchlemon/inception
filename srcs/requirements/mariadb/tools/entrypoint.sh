#!/bin/bash
set -euo pipefail
DATADIR=/var/lib/mysql
SOCKET=/var/run/mysqld/mysqld.sock

echo "[entrypoint] Starting MariaDB initialization process..."

# Check if database needs initialization
NEED_INIT=false

if [ ! -d "$DATADIR/mysql" ]; then
  echo "[entrypoint] No mysql system database found, full initialization needed..."
  NEED_INIT=true
elif [ ! -d "$DATADIR/wordpress" ]; then
  echo "[entrypoint] WordPress database not found, user initialization needed..."
  NEED_INIT=true
fi

if [ "$NEED_INIT" = "true" ]; then
  # Initialize system database if needed
  if [ ! -d "$DATADIR/mysql" ]; then
    echo "[entrypoint] Initializing system database..."
    chown -R mysql:mysql "$DATADIR"
    mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal > /dev/null
  fi
  
  # Start temporary server for setup
  mysqld --skip-networking --socket=$SOCKET &
  temp_pid=$!
  
  # Wait for server to start
  for i in {30..0}; do
    if mysqladmin --socket=$SOCKET ping &>/dev/null; then
      break
    fi
    sleep 1
  done
  
  if ! mysqladmin --socket=$SOCKET ping &>/dev/null; then
    echo "[entrypoint] Failed to start temporary server" >&2
    exit 1
  fi
  
  # Initialize database and users
  /usr/local/bin/init-db.sh --socket=$SOCKET
  
  # Stop temporary server
  mysqladmin --socket=$SOCKET shutdown
  wait $temp_pid
  
  echo "[entrypoint] Database initialization completed"
else
  echo "[entrypoint] Database already exists and is properly initialized"
fi

echo "[entrypoint] Starting MariaDB server..."
exec mysqld_safe

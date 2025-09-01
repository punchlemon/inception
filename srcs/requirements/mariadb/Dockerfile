FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    bash \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/secrets /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init-db.sh /usr/local/bin/init-db.sh
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/init-db.sh /entrypoint.sh

VOLUME /var/lib/mysql

CMD ["/entrypoint.sh"]


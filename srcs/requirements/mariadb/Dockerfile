# Debian (penultimate stable)
FROM debian:bullseye

# パッケージ更新 & MariaDB インストール
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# 設定ファイルをコピー
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 初期化スクリプトをコピー
COPY tools/init-db.sh /docker-entrypoint-initdb.d/init-db.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

# データベースのデータを永続化するためのディレクトリ
VOLUME /var/lib/mysql

# MariaDB をフォアグラウンドで起動
CMD ["mysqld_safe"]


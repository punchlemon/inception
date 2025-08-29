# Debian (penultimate stable) をベースにする
FROM debian:bullseye

# パッケージ更新 & 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    php-mbstring \
    php-xml \
    wget \
    curl \
    unzip \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# PHP-FPM の設定ファイルを差し替え
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# WordPress をダウンロード & 展開
WORKDIR /var/www/html
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xvzf wordpress.tar.gz --strip-components=1 \
    && rm wordpress.tar.gz

# wp-config.php をコピー（環境変数を読む設定にしておく）
COPY conf/wp-config.php /var/www/html/wp-config.php

# www-data を所有者に変更（WordPress 推奨）
RUN chown -R www-data:www-data /var/www/html

# php-fpm をフォアグラウンドで起動
CMD ["php-fpm7.4", "-F"]


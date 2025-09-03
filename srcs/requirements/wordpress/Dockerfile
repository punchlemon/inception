FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    php-mbstring \
    php-xml \
    php-opcache \
    wget \
    curl \
    unzip \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xvzf wordpress.tar.gz --strip-components=1 \
    && rm wordpress.tar.gz

COPY conf/wp-config.php /var/www/html/wp-config.php
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]


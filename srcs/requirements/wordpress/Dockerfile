FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    mariadb-client \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    gnupg \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-opcache \
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


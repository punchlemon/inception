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
    php7.4-curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xvzf wordpress.tar.gz --strip-components=1 \
    && rm wordpress.tar.gz

# Install WP-CLI
RUN curl -L https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY conf/wp-config.php /var/www/html/wp-config.php
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && mkdir -p /run/php \
    && chown -R www-data:www-data /var/www/html

CMD ["/entrypoint.sh"]


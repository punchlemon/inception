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

RUN printf '#!/bin/bash\nset -e\nif grep -q "put your unique phrase here" /var/www/html/wp-config.php; then\n  for k in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do\n    R=$(openssl rand -base64 48 | tr -d "\n");\n    sed -i "s/put your unique phrase here/${R}/" /var/www/html/wp-config.php;\n  done;\nfi\nexec php-fpm -F\n' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]


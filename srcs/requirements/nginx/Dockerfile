FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Remove default site to avoid conflicts
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf || true

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443
CMD ["/entrypoint.sh"]


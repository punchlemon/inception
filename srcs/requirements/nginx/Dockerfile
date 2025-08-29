# ベースイメージは Debian (penultimate stable) か Alpine
FROM debian:bullseye

# パッケージ更新 & 必要なものをインストール
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# SSL証明書を作成（自己署名証明書の例）
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42/OU=student/CN=wil.42.fr" \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt

# nginx.conf をコピー（TLS 1.2/1.3 のみ許可する設定を書く）
COPY conf/nginx.conf /etc/nginx/nginx.conf

# NGINX をフォアグラウンドで実行（daemon off）
CMD ["nginx", "-g", "daemon off;"]


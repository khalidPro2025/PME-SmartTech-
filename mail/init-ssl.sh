#!/bin/bash
SSL_DIR="/tmp/docker-mailserver/ssl"
DOMAIN="mail.smarttech.local"

echo "🔍 Checking SSL certificates for $DOMAIN..."

mkdir -p "$SSL_DIR"

# ------------------------------
# CREATE CERTIFICATES IF MISSING
# ------------------------------
if [[ ! -f "$SSL_DIR/$DOMAIN-key.pem" || ! -f "$SSL_DIR/$DOMAIN-cert.pem" ]]; then
    echo "⚠️ Missing SSL certs. Auto-generating new certificates..."

    openssl req -x509 -nodes -days 3650 \
        -newkey rsa:2048 \
        -keyout "$SSL_DIR/$DOMAIN-key.pem" \
        -out "$SSL_DIR/$DOMAIN-cert.pem" \
        -subj "/CN=$DOMAIN"

    # CA
    openssl req -x509 -nodes -days 3650 \
        -newkey rsa:2048 \
        -keyout "$SSL_DIR/cakey.pem" \
        -out "$SSL_DIR/cacert.pem" \
        -subj "/CN=SmartTech-CA"
else
    echo "✔ SSL certificates already exist."
fi

chmod 600 $SSL_DIR/*.pem

echo "🚀 Starting Docker-Mailserver..."
exec /usr/local/bin/start-mailserver.sh

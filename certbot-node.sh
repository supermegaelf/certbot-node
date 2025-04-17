#!/bin/bash

read -p "Cloudflare email: " CF_EMAIL
read -p "Cloudflare API key: " CF_API_KEY
read -p "Node domain: " SNI_DOMAIN

apt install python3-certbot-dns-cloudflare -y

mkdir -p /root/.secrets/certbot/

cat > /root/.secrets/certbot/cloudflare.ini << EOF
dns_cloudflare_email = "$CF_EMAIL"
dns_cloudflare_api_key = "$CF_API_KEY"
EOF

chmod 700 /root/.secrets/certbot/
chmod 400 /root/.secrets/certbot/cloudflare.ini

certbot certonly --dns-cloudflare \
  --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini \
  -d "*.$SNI_DOMAIN" -d "$SNI_DOMAIN" \
  --non-interactive --agree-tos --email "$CF_EMAIL"

echo "0 3 * * * root /usr/bin/certbot renew --quiet --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini --post-hook 'systemctl reload nginx'" | tee -a /etc/crontab

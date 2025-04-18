#!/bin/bash

read -p $'\033[32mCloudflare email: \033[0m' CF_EMAIL
read -p $'\033[32mCloudflare API key: \033[0m' CF_API_KEY
read -p $'\033[32mNode domain: \033[0m' SNI_DOMAIN

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

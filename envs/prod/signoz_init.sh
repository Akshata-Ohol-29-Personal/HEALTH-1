#!/bin/bash

set -eo pipefail

export SIGNOZ_TAG=v0.14.0
export DEBIAN_FRONTEND=noninteractive

# install tailscale
#
curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg > /usr/share/keyrings/tailscale-archive-keyring.gpg
curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list > /etc/apt/sources.list.d/tailscale.list
apt-get update
apt-get install -y tailscale

# install docker https://docs.docker.com/engine/install/debian/
#
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# install nginx, letsencrypt
#
apt-get install -y certbot nginx
mkdir -p /var/www/signoz.yuvohealth.com/letsencrypt
cat > /etc/nginx/sites-available/signoz.yuvohealth.com <<EOF
server {
        listen 80;
        listen [::]:80;
        server_name signoz.yuvohealth.com;

        location /.well-known/acme-challenge {
                default_type "text/plain";
                root /var/www/signoz.yuvohealth.com/letsencrypt;
        } 

        location / {
                rewrite ^/(.*) https://signoz.yuvohealth.com/\$1;
        }
}
# server {
#         listen 443 ssl;
#         listen [::]:443 ssl;
#         server_name signoz.yuvohealth.com;
#         ssl_certificate /etc/letsencrypt/live/signoz.yuvohealth.com/fullchain.pem;
#         ssl_certificate_key /etc/letsencrypt/live/signoz.yuvohealth.com/privkey.pem;
# 
#         location / {
#                 # First attempt to serve request as file, then
#                 # as directory, then fall back to displaying a 404.
#                 try_files \$uri @signoz;
#         }
# 
#         location @signoz {
#                 proxy_pass http://localhost:3301;
#                 proxy_set_header X-Real-IP \$remote_addr;
#                 proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#                 proxy_set_header Host \$http_host;
#                 proxy_http_version 1.1;
#                 proxy_set_header Upgrade \$http_upgrade;
#                 proxy_set_header Connection "upgrade";
#                 proxy_redirect off;
#                 chunked_transfer_encoding off;
#                 proxy_buffering off;
#                 proxy_cache off;
#         }
# }
EOF
ln -s /etc/nginx/sites-available/signoz.yuvohealth.com /etc/nginx/sites-enabled/signoz.yuvohealth.com
service nginx restart

# install signoz
#
cd /opt
git clone https://github.com/SigNoz/signoz.git
cd /opt/signoz
git checkout ${SIGNOZ_TAG}
cat > /opt/signoz/deploy/docker/clickhouse-setup/otel-collector-tailnet-config.yaml <<EOF
receivers:
  otlp:
    protocols:
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:

exporters:
  otlphttp:
    endpoint: "https://otel-collector:4318"
    tls:
      insecure_skip_verify: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp]
EOF

cat >> /opt/signoz/deploy/docker/clickhouse-setup/docker-compose.yaml <<EOF

  otel-collector-tailnet:
    image: signoz/signoz-otel-collector:0.66.2
    command: ["--config=/etc/otel-collector-tailnet-config.yaml"]
    volumes:
      - ./otel-collector-tailnet-config.yaml:/etc/otel-collector-tailnet-config.yaml
    environment:
      - OTEL_RESOURCE_ATTRIBUTES=host.name=signoz-host,os.type=linux
    ports:
      - "4319:4318"     # OTLP HTTP receiver
    mem_limit: 2000m
    restart: on-failure
    <<: *clickhouse-depend
EOF

# the above are prerequisite steps and do NOT complete the signoz install.
# to complete:
#
# 1. create DNS A record for signoz.yuvohealth.com with host public IP
# 2. login to the host via `gcloud compute ssh`
# 3. `sudo tailscale up`, follow directions to connect
# 5. run `sudo certbot certonly -d signoz.yuvohealth.com --webroot` (/var/www/signoz.yuvohealth.com/letsencrypt for webroot value)
# 6. uncomment https section from nginx conf, restart nginx
# 7. edit /opt/signoz/deploy/docker/clickhouse-setup/docker-compose.yaml
# 8. comment out hotrod, load-hotrod services
# 9. from /opt/signoz/deploy, run `docker compose -f docker/clickhouse-setup/docker-compose.yaml up -d`
# 10. add cron entries to weekly certbot renew and daily nginx reload

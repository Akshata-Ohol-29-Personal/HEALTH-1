#!/bin/bash

set -eo pipefail

CSP_BIN=/usr/local/bin/cloud_sql_proxy
if [ ! -x ${CSP_BIN} ]; then
  curl -sL https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -o ${CSP_BIN}
  chmod +x ${CSP_BIN}
fi

CLOUD_SQL_INSTANCE_NAME=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/attributes/sql_name -H "Metadata-Flavor: Google")
${CSP_BIN} -instances=${CLOUD_SQL_INSTANCE_NAME}=tcp:5432 &

LOOKER_PUBKEY=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/attributes/looker_pubkey -H "Metadata-Flavor: Google")
if [ -n "${LOOKER_PUBKEY}" ]; then
  useradd -m looker
  mkdir -p /home/looker/.ssh
  echo ${LOOKER_PUBKEY} > /home/looker/.ssh/authorized_keys
  chown -R looker:looker /home/looker/.ssh
  chmod 700 /home/looker/.ssh
  chmod 600 /home/looker/.ssh/authorized_keys
  echo looker user account created and public key saved to authorized_keys
fi

#!/bin/bash

export HOME_DIR="$PWD"

rm -rf traefik/certs
cd $HOME_DIR/scripts/openssl
source gen_mkcert.sh
mv $HOME_DIR/scripts/openssl/certs $HOME_DIR/traefik
cd $HOME_DIR

NETWORK_NAME="web"
SUBNET="172.20.0.0/16"

# Verifica se a rede já existe
if [ ! "$(docker network ls --filter name=^${NETWORK_NAME}$ --format="{{ .Name }}")" ]; then
    echo "Criando a rede ${NETWORK_NAME}..."
    docker network create --subnet=${SUBNET} ${NETWORK_NAME}
else
    echo "A rede ${NETWORK_NAME} já existe."
fi

docker compose -f traefik/docker-compose-traefik.yml up -d

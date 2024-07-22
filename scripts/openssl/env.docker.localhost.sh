#!/bin/bash

set -a # Ativa a exportação automática de variáveis

# Definição das variáveis de ambiente
COUNTRY="BR"
STATE="Ceara"
LOCALITY="Fortaleza"
ORGANIZATION="Universidade Federal do Ceara"
ORG_UNIT="UFC"
COMMON_NAME="petrvs.docker.localhost"
WILDCARD_COMMON_NAME="docker.localhost"
EMAIL="diego@diego"
EXPIRATION_DAYS=1825
KEY_SIZE=2048

COMMON_KEY="${COMMON_NAME}.key.pem"
COMMON_CSR="${COMMON_NAME}.csr.pem"
COMMON_CRT="${COMMON_NAME}.crt.pem"
WILDCARD_KEY="wildcard.${WILDCARD_COMMON_NAME}.key.pem"
WILDCARD_CSR="wildcard.${WILDCARD_COMMON_NAME}.csr.pem"
WILDCARD_CRT="wildcard.${WILDCARD_COMMON_NAME}.crt.pem"
CERT_EXT="cert_ext.cnf"
WILDCARD_EXT="wildcard_ext.cnf"

set +a # Desativa a exportação automática de variáveis

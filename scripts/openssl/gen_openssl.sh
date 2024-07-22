#!/bin/bash

source env.docker.localhost.sh

DIRECTORY_PATH="certs"

if [ -d "${DIRECTORY_PATH}" ]; then
    echo "O diretório '${DIRECTORY_PATH}' já existe."
else
    echo "O diretório '${DIRECTORY_PATH}' não existe. Criando o diretório..."
    mkdir -p "${DIRECTORY_PATH}"
    cd "${DIRECTORY_PATH}"
fi

# Cria o arquivo de configuração
cat >"${CERT_EXT}" <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
C = ${COUNTRY}
ST = ${STATE}
L = ${LOCALITY}
O = ${ORGANIZATION}
OU = ${ORG_UNIT}
CN = ${COMMON_NAME}
emailAddress = ${EMAIL}

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${COMMON_NAME}
DNS.2 = petrvs.ufc.localhost
DNS.3 = localhost
EOF

# Cria o arquivo de configuração
cat >"${WILDCARD_EXT}" <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
C = ${COUNTRY}
ST = ${STATE}
L = ${LOCALITY}
O = ${ORGANIZATION}
OU = ${ORG_UNIT}
CN = *.${WILDCARD_COMMON_NAME}
emailAddress = ${EMAIL}

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${WILDCARD_COMMON_NAME}
EOF

# Gera a chave privada
openssl genrsa -out "${COMMON_KEY}" ${KEY_SIZE}

# Gera o CSR usando o arquivo de configuração
openssl req -new -key "${COMMON_KEY}" -out "${COMMON_CSR}" -config "${CERT_EXT}"

# Gera o certificado autoassinado
openssl x509 -req -days ${EXPIRATION_DAYS} -in "${COMMON_CSR}" -signkey "${COMMON_KEY}" -out "${COMMON_CRT}" -extensions req_ext -extfile "${CERT_EXT}"

# Gera a chave privada
openssl genrsa -out "${WILDCARD_KEY}" ${KEY_SIZE}

# Gera o CSR usando o arquivo de configuração
openssl req -new -key "${WILDCARD_KEY}" -out "${WILDCARD_CSR}" -config "${WILDCARD_EXT}"

# Gera o certificado autoassinado
openssl x509 -req -days ${EXPIRATION_DAYS} -in "${WILDCARD_CSR}" -signkey "${WILDCARD_KEY}" -out "${WILDCARD_CRT}" -extensions req_ext -extfile "${WILDCARD_EXT}"

# Limpa os arquivos de configuração e CSR
rm "${CERT_EXT}" "${WILDCARD_EXT}" "${COMMON_CSR}" "${WILDCARD_CSR}"

echo "Certificados gerados com sucesso!"

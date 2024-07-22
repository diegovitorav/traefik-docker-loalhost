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

# Instala mkcert se não estiver instalado
if ! command -v mkcert &>/dev/null; then
    echo "mkcert não está instalado. Instalando..."
    sudo apt update
    sudo apt install -y libnss3-tools
    wget -O mkcert https://dl.filippo.io/mkcert/latest?for=linux/amd64
    chmod +x mkcert
    sudo mv mkcert /usr/local/bin/
fi

# Instala o CA local mkcert se não estiver instalado
mkcert -install

# Gera um CA usando mkcert
mkcert -CAROOT
CAROOT=$(mkcert -CAROOT)
CA_CERT="${CAROOT}/rootCA.pem"
CA_KEY="${CAROOT}/rootCA-key.pem"

# Cria o arquivo de configuração para petrvs.docker.localhost
cat >${CERT_EXT} <<EOF
[req]
distinguished_name = req_distinguished_name
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

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign

[alt_names]
DNS.1 = ${COMMON_NAME}
DNS.2 = localhost
EOF

# Cria o arquivo de configuração para *.docker.localhost
cat >${WILDCARD_EXT} <<EOF
[req]
distinguished_name = req_distinguished_name
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

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign

[alt_names]
DNS.1 = *.${WILDCARD_COMMON_NAME}
EOF

# Gera a chave privada
openssl genrsa -out "${COMMON_KEY}" ${KEY_SIZE}

# Gera o CSR usando o arquivo de configuração
openssl req -new -key "${COMMON_KEY}" -out "${COMMON_CSR}" -config ${CERT_EXT}

# Gera a chave privada
openssl genrsa -out "${WILDCARD_KEY}" ${KEY_SIZE}

# Gera o CSR usando o arquivo de configuração
openssl req -new -key "${WILDCARD_KEY}" -out "${WILDCARD_CSR}" -config ${WILDCARD_EXT}

# Assina os CSRs usando o CA gerado pelo mkcert
openssl x509 -req -in "${COMMON_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${COMMON_CRT}" -days ${EXPIRATION_DAYS} -extfile ${CERT_EXT} -extensions req_ext
openssl x509 -req -in "${WILDCARD_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${WILDCARD_CRT}" -days ${EXPIRATION_DAYS} -extfile ${WILDCARD_EXT} -extensions req_ext

# Limpa os arquivos de configuração e CSR
rm ${CERT_EXT} ${WILDCARD_EXT} "${COMMON_CSR}" "${WILDCARD_CSR}"

echo "Certificados gerados com sucesso!"

#!/bin/bash

source env.docker.localhost.sh

# Função para exibir informações de um certificado
show_certificate_info() {
    CERT_FILE="$1"
    echo "---------------------------------------------------------"
    echo "Informações do certificado: ${CERT_FILE}"
    echo "---------------------------------------------------------"
    openssl x509 -in "${CERT_FILE}" -text -noout
    echo "---------------------------------------------------------"
    echo
}

# Exibe informações do certificado
show_certificate_info "certs/${COMMON_CRT}"

# Exibe informações do certificado
show_certificate_info "certs/${WILDCARD_CRT}"

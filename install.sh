#!/bin/bash

set -euo pipefail

SCRIPT_NAME="install.sh"

log_info() {
    echo "[INFO] ${SCRIPT_NAME}: $1"
}

log_error() {
    echo "[ERROR] ${SCRIPT_NAME}: $1" >&2
}

log_info "Permissões de root validadas."

TARGET_DIR="/usr/local/bin"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)/scripts"

log_info "Diretório de origem: ${SOURCE_DIR}"
log_info "Diretório de destino: ${TARGET_DIR}"

# Validação de execução como root
if [[ "${EUID}" -ne 0 ]]; then
    log_error "Este script deve ser executado como root."
    exit 1
fi


mkdir -p "${TARGET_DIR}"

for script in "${SOURCE_DIR}"/lxt-*; do
    if [[ -f "$script" ]]; then
        cp "$script" "${TARGET_DIR}/"
        chmod 755 "${TARGET_DIR}/$(basename "$script")"
        log_info "Instalado: $(basename "$script")"
    fi
done

log_info "Instalação concluída com sucesso."

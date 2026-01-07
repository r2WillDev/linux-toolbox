#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="uninstall.sh"

log_error() {
    echo "[ERROR] ${SCRIPT_NAME}: $1" >&2
}

log_info() {
    echo "[INFO] ${SCRIPT_NAME}: $1"
}

# Validação de execução como root
if [[ "${EUID}" -ne 0 ]]; then
    log_error "Este script deve ser executado como root."
    exit 1
fi

log_info "Iniciando remoção da Linux Toolbox..."

BIN_DIR="/usr/local/bin"

TOOLS=(
    "lxt-backup"
    "lxt-disk"
    "lxt-find"
    "lxt-hello"
    "lxt-ports"
    "lxt-proc"
)

for tool in "${TOOLS[@]}"; do
    TARGET="${BIN_DIR}/${tool}"

    if [[ -f "${TARGET}" ]]; then
        log_info "Removendo ${TARGET}"
        rm -f "${TARGET}"
    else
        log_info "Arquivo não encontrado (ignorado): ${TARGET}"
    fi
done

log_info "Remoção da Linux Toolbox concluída."

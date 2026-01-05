#!/usr/bin/env bash
# check-ports.sh - Verificação de portas em escuta no sistema
#
# Uso:
#   ./check-ports.sh [PORTA]
#
# Exemplos:
#   ./check-ports.sh
#   ./check-ports.sh 22
#
# Saídas:
#   0 - sucesso
#   1 - erro de uso
#   2 - erro de execução

set -euo pipefail
IFS=$'\n\t'

PROGRAM_NAME="$(basename "$0")"
PROGRAM_DESC="Verificação de portas em escuta no sistema"

usage() {
  cat <<USAGE
${PROGRAM_NAME} - ${PROGRAM_DESC}

Uso:
  ${PROGRAM_NAME} [PORTA]

Descrição:
  Lista portas em escuta no sistema.
  Se PORTA for informada, filtra apenas a porta especificada.

Exemplos:
  ${PROGRAM_NAME}
  ${PROGRAM_NAME} 22
USAGE
}

log_info() {
  printf '%s\n' "[INFO] ${PROGRAM_NAME}: $*" >&2
}

log_error() {
  printf '%s\n' "[ERROR] ${PROGRAM_NAME}: $*" >&2
}

# -------------------------
# Localização segura do binário ss
# -------------------------
SS_BIN="$(command -v ss || true)"

if [[ -z "$SS_BIN" ]]; then
  log_error "Comando 'ss' não encontrado. Verifique se o pacote iproute2 está instalado."
  exit 2
fi

# Aviso se não for root (limitação conhecida)
if [[ "$(id -u)" -ne 0 ]]; then
  log_info "Não root: nomes de processos e PIDs podem não ser exibidos."
fi

# -------------------------
# Validação de argumento
# -------------------------
PORT="${1:-}"

if [[ -n "$PORT" && ! "$PORT" =~ ^[0-9]+$ ]]; then
  log_error "Porta inválida: $PORT"
  usage
  exit 1
fi

# -------------------------
# Execução principal
# -------------------------
if [[ -z "$PORT" ]]; then
  log_info "Listando todas as portas em escuta"
  "$SS_BIN" -tuln
else
  log_info "Listando portas em escuta filtrando pela porta: $PORT"
  "$SS_BIN" -tuln | grep -E ":${PORT}\b" || true
fi

exit 0


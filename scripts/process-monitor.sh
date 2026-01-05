#!/usr/bin/env bash
# template.sh - Template base para scripts Bash do projeto Linux Toolbox
#
# Uso:
#   ./scripts/template.sh [-h|--help] [--] [ARGS...]
#
# Objetivo:
#   Fornecer estrutura mínima: shebang, modos seguros, help, logging e parsing simples.
#
# Saídas:
#   0 - sucesso
#   1 - erro de uso
#   2 - erro de execução

set -euo pipefail
IFS=$'\n\t'

PROGRAM_NAME="$(basename "$0")"
PROGRAM_DESC="Template base para scripts Bash do projeto Linux Toolbox"

usage() {
  cat <<USAGE
${PROGRAM_NAME} - ${PROGRAM_DESC}

Uso:
  ${PROGRAM_NAME} [-h|--help] [--] [ARGS...]

Opções:
  -h, --help    Mostrar esta ajuda

Exemplos:
  ${PROGRAM_NAME} --some-arg value
USAGE
}

log_info() {
  printf '%s\n' "[INFO] ${PROGRAM_NAME}: $*" >&2
}

log_error() {
  printf '%s\n' "[ERROR] ${PROGRAM_NAME}: $*" >&2
}

# Parse basic options
while [[ ${#:-} -gt 0 ]]; do
  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      log_error "Opção desconhecida: ${1}"
      usage
      exit 1
      ;;
    *)
      # positional args begin
      break
      ;;
  esac
done

# Placeholder for core logic
main() {
  local mode="${1:-}"
  local limit="${2:-10}"

  if [[ -z "$mode" ]]; then
    log_error "Modo obrigatório: cpu ou mem"
    usage
    exit 1
  fi

  if [[ "$mode" != "cpu" && "$mode" != "mem" ]]; then
    log_error "Modo inválido: $mode (use cpu ou mem)"
    exit 1
  fi

  if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
    log_error "Quantidade inválida: $limit"
    exit 1
  fi

  log_info "Monitorando processos por $mode (top $limit)"

  if [[ "$mode" == "cpu" ]]; then
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n "$((limit + 1))"
  else
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n "$((limit + 1))"
  fi

  return 0
}


main "$@"

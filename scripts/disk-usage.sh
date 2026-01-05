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
  local path="${1:-/}"
  local limit=10

  if [[ ! -d "$path" ]]; then
    log_error "Caminho inválido ou inexistente: $path"
    exit 2
  fi

  log_info "Resumo geral de uso de disco (df -h)"
  df -h

  echo
  log_info "Análise específica do caminho: $path"
  echo "Maiores diretórios em $path (top $limit):"
  echo

  du -h --max-depth=1 "$path" 2>/dev/null | sort -hr | head -n "$limit"

  return 0
}


main "$@"

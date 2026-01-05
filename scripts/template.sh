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
  log_info "Template carregado com sucesso. Substitua este bloco pela lógica do script."
  # exemplo:
  # echo "Positional args: $*"
  return 0
}

main "$@"

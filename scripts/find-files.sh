#!/usr/bin/env bash
# Nome: find-files.sh
# Descrição: Busca arquivos de forma segura por nome parcial ou extensão.
# Uso: ./scripts/find-files.sh [-n NOME | -e EXT] [-d DIR]
# Autor: O2B Team
#
# Requisitos:
#   - Funciona como usuário normal (mas não encontrará arquivos em pastas protegidas como /root).
#   - Use 'sudo' se precisar buscar em diretórios do sistema.
#
# Saídas:
#   0 - sucesso
#   1 - erro de uso ou conflito de argumentos
#   2 - erro de validação (diretório inexistente/sem permissão)

set -euo pipefail
IFS=$'\n\t'

PROGRAM_NAME="$(basename "$0")"

# --- FUNÇÕES DE LOG (PADRÃO O2B) ---
log_info() {
  printf '%s\n' "[INFO] ${PROGRAM_NAME}: $*" >&2
}

log_warn() {
  printf '%s\n' "[WARN] ${PROGRAM_NAME}: $*" >&2
}

log_error() {
  printf '%s\n' "[ERROR] ${PROGRAM_NAME}: $*" >&2
}

# --- FUNÇÃO USAGE ---
usage() {
  cat <<USAGE
${PROGRAM_NAME} - Busca avançada de arquivos

Uso:
  ${PROGRAM_NAME} [-n NOME | -e EXT] [-d DIRETORIO]

Opções:
  -n NOME       Busca por parte do nome (ex: "nginx" acha "nginx.conf")
  -e EXT        Busca por extensão exata (ex: "log" acha "*.log")
  -d DIRETORIO  Diretório base para a busca (Padrão: atual '.')
  -h, --help    Mostrar esta ajuda

Exemplos:
  ${PROGRAM_NAME} -n passwd -d /etc
  ${PROGRAM_NAME} -e js -d /var/www
USAGE
  exit 1
}

# --- PARSING ---
search_name=""
search_ext=""
base_dir="."

while [[ ${#:-} -gt 0 ]]; do
  case "${1:-}" in
    -h|--help) usage ;;
    -n) search_name="${2:-}"; shift 2 ;;
    -e) search_ext="${2:-}"; shift 2 ;;
    -d) base_dir="${2:-}"; shift 2 ;;
    --) shift; break ;;
    -*) log_error "Opção desconhecida: ${1}"; usage ;;
    *)  log_error "Argumento inesperado: ${1}"; usage ;;
  esac
done

# --- MAIN & SEGURANÇA ---
main() {
  # 1. Validação de Diretório
  if [[ ! -d "$base_dir" ]]; then
    log_error "Diretório inválido ou inexistente: $base_dir"
    exit 2
  fi

  if [[ ! -r "$base_dir" ]]; then
    log_error "Sem permissão de leitura no diretório base: $base_dir"
    exit 2
  fi

  # 2. Aviso de Privilégio (Step 5)
  if [[ "$(id -u)" -ne 0 ]]; then
    # Se o diretório base for de sistema (ex: /var, /etc, /), avisa.
    if [[ "$base_dir" == "/" || "$base_dir" =~ ^/(var|etc|root|boot) ]]; then
      log_warn "Buscando em área de sistema como usuário normal."
      log_warn "Arquivos protegidos serão ignorados (permissão negada)."
    fi
  fi

  # 3. Validação Lógica
  if [[ -n "$search_name" && -n "$search_ext" ]]; then
    log_error "Conflito: Escolha buscar por nome (-n) OU extensão (-e), não ambos."
    usage
  fi

  if [[ -z "$search_name" && -z "$search_ext" ]]; then
    log_error "Critério ausente: Informe nome (-n) ou extensão (-e)."
    usage
  fi

  # 4. Execução
  log_info "Diretório base validado: [$base_dir]"

  if [[ -n "$search_name" ]]; then
    log_info "Buscando por nome: [$search_name]"
    find "$base_dir" -type f -name "*${search_name}*" 2>/dev/null || true
  fi

  if [[ -n "$search_ext" ]]; then
    log_info "Buscando por extensão: [.$search_ext]"
    find "$base_dir" -type f -name "*.${search_ext}" 2>/dev/null || true
  fi

  return 0
}

main "$@"

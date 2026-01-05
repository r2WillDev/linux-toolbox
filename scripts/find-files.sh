#!/usr/bin/env bash
# find-files.sh - Busca avançada de arquivos
#
# Uso:
#   ./scripts/find-files.sh [-n NOME | -e EXT] [-d DIR]
#
# Objetivo:
#   Localizar arquivos por nome ou extensão.
#   Valida argumentos conflitantes e diretórios inexistentes.

set -euo pipefail
IFS=$'\n\t'

PROGRAM_NAME="$(basename "$0")"

# --- INICIALIZAÇÃO DE VARIÁVEIS (OBRIGATÓRIO COM set -u) ---
search_name=""
search_ext=""
base_dir="."

# --- FUNÇÕES ---
usage() {
  cat <<USAGE
${PROGRAM_NAME} - Busca avançada de arquivos

Uso:
  ${PROGRAM_NAME} -n NOME [-d DIRETORIO]
  ${PROGRAM_NAME} -e EXTENSAO [-d DIRETORIO]

Opções:
  -n NOME       Buscar arquivo pelo nome (glob pattern)
  -e EXTENSAO   Buscar arquivos por extensão (ex: log, conf)
  -d DIRETORIO  Diretório base da busca (padrão: .)
  -h, --help    Mostrar esta ajuda

Exemplos:
  ${PROGRAM_NAME} -n hosts -d /etc
  ${PROGRAM_NAME} -e log -d /var/log
USAGE
}

log_info() {
  printf '%s\n' "[INFO] ${PROGRAM_NAME}: $*" >&2
}

log_error() {
  printf '%s\n' "[ERROR] ${PROGRAM_NAME}: $*" >&2
}

# --- PARSING ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -n)
      search_name="${2:-}"
      shift 2
      ;;
    -e)
      search_ext="${2:-}"
      shift 2
      ;;
    -d)
      base_dir="${2:-}"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      log_error "Opção desconhecida: $1"
      usage
      exit 1
      ;;
    *)
      log_error "Argumento inesperado: $1"
      usage
      exit 1
      ;;
  esac
done

# --- MAIN & VALIDAÇÃO ---
main() {
  # 1. Valida conflito (nome E extensão)
  if [[ -n "$search_name" && -n "$search_ext" ]]; then
    log_error "Conflito: Use apenas -n (nome) OU -e (extensão), não ambos."
    usage
    exit 1
  fi

  # 2. Valida ausência (nenhum critério)
  if [[ -z "$search_name" && -z "$search_ext" ]]; then
    log_error "Faltando critério: Informe -n (nome) ou -e (extensão)."
    usage
    exit 1
  fi

  # 3. Valida diretório
  if [[ ! -d "$base_dir" ]]; then
    log_error "Diretório inválido ou inexistente: $base_dir"
    exit 2
  fi

  # 4. Feedback de Sucesso (Validação dos Inputs)
  log_info "Parâmetros aceitos com sucesso."
  log_info "Diretório: [$base_dir]"

  if [[ -n "$search_name" ]]; then
    log_info "Modo: Busca por NOME = [$search_name]"
  else
    log_info "Modo: Busca por EXTENSÃO = [$search_ext]"
  fi

  if [[ -n "$search_name" ]]; then
    log_info "Iniciando busca por nome: [$search_name]"
    find "$base_dir" -type f -name "*$search_name*" 2>/dev/null
    exit 0
  fi

  if [[ -n "$search_ext" ]]; then
    log_info "Iniciando busca por extensão: [.$search_ext]"
    find "$base_dir" -type f -name "*.$search_ext" 2>/dev/null
    exit 0
  fi




  return 0
}

main "$@"

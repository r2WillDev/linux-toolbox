#!/usr/bin/env bash
# backup.sh - Backup simples de arquivos e diretórios com tar.gz
#
# Uso:
#   ./scripts/backup.sh -s ORIGEM -d DESTINO
#
# Objetivo:
#   Validar entradas e criar backup compactado.
#   Trata exit codes do tar de forma inteligente (0=ok, 1/2=aviso, >2=erro).

set -euo pipefail
IFS=$'\n\t'

PROGRAM_NAME="$(basename "$0")"

# --- INICIALIZAÇÃO DE VARIÁVEIS ---
source_path=""
dest_dir=""

# --- FUNÇÕES ---
usage() {
  cat <<USAGE
${PROGRAM_NAME} - Backup simples de arquivos e diretórios

Uso:
  ${PROGRAM_NAME} -s ORIGEM -d DESTINO

Opções:
  -s ORIGEM     Arquivo ou diretório de origem
  -d DESTINO    Diretório onde o backup será salvo
  -h, --help    Mostrar esta ajuda
USAGE
}

log_info() {
  printf '%s\n' "[INFO] ${PROGRAM_NAME}: $*" >&2
}

log_warn() {
  printf '%s\n' "[WARN] ${PROGRAM_NAME}: $*" >&2
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
    -s)
      source_path="${2:-}"
      shift 2
      ;;
    -d)
      dest_dir="${2:-}"
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

# --- MAIN ---
main() {
  # 1. Validações
  if [[ -z "$source_path" || -z "$dest_dir" ]]; then
    log_error "Informe origem (-s) e destino (-d)"
    usage
    exit 1
  fi

  if [[ ! -e "$source_path" ]]; then
    log_error "Origem inexistente: $source_path"
    exit 2
  fi

  if [[ ! -d "$dest_dir" ]]; then
    log_error "Destino inválido (não é diretório): $dest_dir"
    exit 2
  fi

  # 2. Definição de nomes
  local timestamp
  timestamp=$(date +"%Y%m%d_%H%M%S")
  
  local source_name
  source_name=$(basename "$source_path")
  
  local backup_file="backup_${source_name}_${timestamp}.tar.gz"
  local backup_path="${dest_dir}/${backup_file}"

  log_info "Iniciando backup de [$source_path] para [$backup_path]..."

  # 3. Execução do Backup
  # Inicializamos com 0 para garantir estado limpo
  local tar_exit_code=0
  
  # Executamos o tar. 
  # O '|| tar_exit_code=$?' impede que o 'set -e' mate o script se o tar retornar != 0
  tar -czf "$backup_path" -C "$(dirname "$source_path")" "$source_name" 2>/dev/null || tar_exit_code=$?

  # 4. Análise Profissional do Exit Code
  if [[ $tar_exit_code -eq 0 ]]; then
    log_info "Backup criado com SUCESSO absoluto."
    
  elif [[ $tar_exit_code -eq 1 || $tar_exit_code -eq 2 ]]; then
    # Código 1 (diff) ou 2 (erro não fatal) -> Backup Válido com Avisos
    log_warn "Backup criado com avisos (arquivos ignorados ou permissões insuficientes)."
    log_info "Arquivo válido gerado: $backup_path"
    
  else
    # Códigos maiores (ex: erro de I/O, disco cheio) -> Falha Real
    log_error "Falha CRÍTICA ao criar backup (Exit code: $tar_exit_code)."
    # Opcional: remover o arquivo se for lixo, mas aqui vamos apenas sair com erro
    exit 3
  fi

  # 5. Segurança (Permissões)
  if [[ -f "$backup_path" ]]; then
    chmod 600 "$backup_path"
    log_info "Permissões ajustadas (600)."
  fi

  return 0
}

main "$@"

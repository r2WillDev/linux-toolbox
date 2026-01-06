#!/usr/bin/env bash
# Nome: backup.sh
# Descrição: Backup simples de arquivos e diretórios com tar.gz.
# Uso: ./scripts/backup.sh -s ORIGEM -d DESTINO
# Autor: O2B Team
#
# Requisitos:
#   - Funciona como usuário normal ou root.
#   - Root é recomendado caso a ORIGEM contenha arquivos do sistema (ex: /etc).
#   - Requer permissão de escrita no diretório de DESTINO.
#
# Saídas:
#   0 - sucesso absoluto
#   1 - erro de uso ou parâmetros
#   2 - erro de validação (permissões/existência)
#   3 - falha crítica na execução do tar

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

# --- VERIFICAÇÃO DE PRIVILÉGIOS (SECURITY HARDENING) ---
if [[ "$(id -u)" -ne 0 ]]; then
  log_warn "Executando como usuário normal (não-root)."
  log_warn "Caso a origem contenha arquivos protegidos, o backup pode ficar incompleto."
fi

# --- INICIALIZAÇÃO DE VARIÁVEIS GLOBAIS ---
# Globais usam UPPER_CASE para Clean Code
SOURCE_PATH=""
DEST_DIR=""

# --- FUNÇÃO USAGE ---
usage() {
  cat <<USAGE
${PROGRAM_NAME} - Backup seguro de arquivos e diretórios

Uso:
  ${PROGRAM_NAME} -s ORIGEM -d DESTINO

Argumentos:
  -s ORIGEM     Arquivo ou diretório a ser copiado (Obrigatório)
  -d DESTINO    Diretório onde o arquivo .tar.gz será salvo (Obrigatório)

Opções:
  -h, --help    Mostrar esta ajuda

Exemplos:
  ${PROGRAM_NAME} -s /etc -d /backup
  ${PROGRAM_NAME} -s /var/www/html -d /tmp
USAGE
  exit 1
}

# --- PARSING ---
while [[ ${#:-} -gt 0 ]]; do
  case "${1:-}" in
    -h|--help)
      usage
      ;;
    -s)
      SOURCE_PATH="${2:-}"
      shift 2
      ;;
    -d)
      DEST_DIR="${2:-}"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      log_error "Opção desconhecida: ${1}"
      usage
      ;;
    *)
      log_error "Argumento inesperado: ${1}"
      usage
      ;;
  esac
done

# --- MAIN & VALIDAÇÃO DEFENSIVA ---
main() {
  # 1. Validação de Argumentos Obrigatórios
  if [[ -z "${SOURCE_PATH}" || -z "${DEST_DIR}" ]]; then
    log_error "Parâmetros obrigatórios ausentes."
    usage
  fi

  # 2. Blindagem da ORIGEM
  if [[ ! -e "${SOURCE_PATH}" ]]; then
    log_error "Origem inexistente: ${SOURCE_PATH}"
    exit 2
  fi

  if [[ ! -r "${SOURCE_PATH}" ]]; then
    log_error "Sem permissão de leitura na origem: ${SOURCE_PATH}"
    exit 2
  fi

  # 3. Blindagem do DESTINO
  if [[ ! -d "${DEST_DIR}" ]]; then
    log_error "Destino inválido (não é um diretório): ${DEST_DIR}"
    exit 2
  fi

  if [[ ! -w "${DEST_DIR}" ]]; then
    log_error "Sem permissão de escrita no destino: ${DEST_DIR}"
    exit 2
  fi

  # 4. Preparação
  # Variáveis locais usam lower_case e snake_case
  local timestamp
  timestamp=$(date +"%Y%m%d_%H%M%S")

  local source_name
  source_name=$(basename "${SOURCE_PATH}")

  local backup_file="backup_${source_name}_${timestamp}.tar.gz"
  local backup_path="${DEST_DIR}/${backup_file}"

  log_info "Origem validada: [${SOURCE_PATH}]"
  log_info "Destino validado: [${DEST_DIR}]"
  log_info "Iniciando compressão para: ${backup_path}..."

  # 5. Execução Robusta (Lógica de Exit Codes do tar)
  local tar_exit_code=0

  # Executa tar silenciando stderr padrão e capturando código
  # Uso estrito de aspas em todas as variáveis
  tar -czf "${backup_path}" -C "$(dirname "${SOURCE_PATH}")" "${source_name}" 2>/dev/null || tar_exit_code=$?

  # 6. Análise de Resultado
  if [[ "${tar_exit_code}" -eq 0 ]]; then
    log_info "Backup criado com SUCESSO absoluto."

  elif [[ "${tar_exit_code}" -eq 1 || "${tar_exit_code}" -eq 2 ]]; then
    # Código 1/2 = Sucesso parcial
    log_warn "Backup concluído com AVISOS (alguns arquivos ignorados/bloqueados)."
    log_info "Arquivo gerado e válido: ${backup_path}"

  else
    # Código > 2 = Falha real
    log_error "Falha CRÍTICA ao criar backup (Exit code: ${tar_exit_code})."
    
    # Guarda de Comando Perigoso: Verifica se a variável não é vazia antes de deletar
    if [[ -n "${backup_path}" && -f "${backup_path}" ]]; then
      rm -f "${backup_path}"
    fi
    
    exit 3
  fi

  # 7. Segurança Final (Permissões)
  if [[ -f "${backup_path}" ]]; then
    chmod 600 "${backup_path}"
    log_info "Permissões ajustadas (600 - apenas dono lê)."
  fi

  return 0
}

main "$@"

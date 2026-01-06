#!/usr/bin/env bash
# Nome: check-ports.sh
# Descrição: Verifica portas TCP/UDP em escuta (Listening) usando ss.
# Uso: ./scripts/check-ports.sh [PORTA]
# Autor: O2B Team
#
# Requisitos:
#   - Pacote 'iproute2' instalado.
#   - Funciona como usuário normal (visibilidade parcial).
#   - Requer root (sudo) para exibir PIDs e nomes dos processos.
#
# Saídas:
#   0 - sucesso
#   1 - erro de uso ou porta inválida
#   2 - erro de dependência (comando ss ausente)

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

# --- FUNÇÃO USAGE PADRONIZADA ---
usage() {
  cat <<USAGE
${PROGRAM_NAME} - Verificação de portas em escuta

Uso:
  ${PROGRAM_NAME} [PORTA]

Argumentos:
  PORTA         Número da porta para filtrar (Opcional)
                Se omitido, lista todas as portas em escuta.

Opções:
  -h, --help    Mostrar esta ajuda

Exemplos:
  ${PROGRAM_NAME}       # Lista tudo
  ${PROGRAM_NAME} 22    # Verifica apenas SSH
  ${PROGRAM_NAME} 80    # Verifica apenas Web
USAGE
  exit 1
}

# --- PARSING ---
while [[ ${#:-} -gt 0 ]]; do
  case "${1:-}" in
    -h|--help)
      usage
      ;;
    -*)
      log_error "Opção desconhecida: ${1}"
      usage
      ;;
    *)
      # Argumento encontrado (a porta), paramos o loop de flags
      break
      ;;
  esac
done

# --- MAIN & VALIDAÇÃO DEFENSIVA ---
main() {
  local target_port="${1:-}"

  # 1. Blindagem de Dependência
  local ss_cmd
  ss_cmd="$(command -v ss || true)"

  if [[ -z "${ss_cmd}" ]]; then
    log_error "Comando 'ss' não encontrado. O pacote 'iproute2' é necessário."
    log_error "Instale com: sudo apt install -y iproute2"
    exit 2
  fi

  # 2. Análise de Privilégios (Hybrid Mode)
  # Uso de Array para permitir quoting seguro: "${ss_opts[@]}"
  local ss_opts=(-tuln)

  if [[ "$(id -u)" -ne 0 ]]; then
    # Snippet de Aviso (Script Híbrido)
    log_warn "Executando como usuário normal. Alguns detalhes (PIDs/Nomes) podem estar ocultos."
    log_warn "Para visualização completa, considere usar 'sudo'."
  else
    # Se for root, adiciona -p para ver Processos
    ss_opts+=(-p)
  fi

  # 3. Validação de Porta (Se fornecida)
  if [[ -n "${target_port}" ]]; then
    # Verifica se é número usando Regex seguro
    if ! [[ "${target_port}" =~ ^[0-9]+$ ]]; then
      log_error "Porta inválida: ${target_port} (deve ser numérica)"
      exit 1
    fi

    # Verifica range válido (1-65535) com aritmética moderna
    if (( target_port < 1 || target_port > 65535 )); then
      log_error "Porta fora do intervalo TCP/IP (1-65535): ${target_port}"
      exit 1
    fi

    log_info "Verificando especificamente a porta: ${target_port}"
    
    # Executa ss com array expandido e filtra (stdout limpo)
    # grep -E ":PORTA($|\s)" garante que ":22" não case com ":2222"
    "${ss_cmd}" "${ss_opts[@]}" | grep -E ":${target_port}($|\s)" || {
      log_info "Nenhum serviço encontrado escutando na porta ${target_port}."
      return 0
    }

  else
    # 4. Modo Listagem Geral
    log_info "Listando todas as portas em escuta..."
    
    # Executa ss (stdout limpo)
    "${ss_cmd}" "${ss_opts[@]}" | grep -E "State|LISTEN"
  fi

  return 0
}

main "$@"

#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/scripts"
CONF_FILE="$HOME/.claude/statusline.conf"
SETTINGS="$HOME/.claude/settings.json"

install_pkg() {
  local pkg="$1"
  echo "  → Instalando $pkg..."
  if command -v brew &>/dev/null; then
    brew install "$pkg"
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y "$pkg"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$pkg"
  elif command -v yum &>/dev/null; then
    sudo yum install -y "$pkg"
  else
    echo "  ✗ No se encontró un package manager compatible. Instalá '$pkg' manualmente."
    exit 1
  fi
}

echo "→ Verificando dependencias..."
for cmd in jq git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "  ✗ '$cmd' no encontrado"
    install_pkg "$cmd"
  fi
done
echo "  ✓ jq y git disponibles"
echo ""

NAMES=("modelo"     "usuario"             "carpeta"                    "branch"            "contexto"                   "tokens"                     "costo"                       "rate_limit"                        "alertas")
DESCS=("Modelo activo de Claude" "Usuario del sistema" "Directorio de trabajo actual" "Branch git activo" "Barra de uso del contexto" "Tokens de entrada y salida" "Costo acumulado de la sesión" "Rate limit con countdown al reset" "Alertas de contexto lleno")
VARS=( "SHOW_MODEL"  "SHOW_USER"           "SHOW_DIR"                   "SHOW_BRANCH"       "SHOW_CONTEXT"               "SHOW_TOKENS"                "SHOW_COST"                   "SHOW_RATE"                         "SHOW_ALERTS")
SEL=(   1             1                     1                             1                   1                             1                            1                             0                                   1)

COUNT=${#NAMES[@]}
CUR=0

draw() {
  clear
  printf "\n  Configurá los elementos del statusline\n"
  printf "  ↑↓ navegar  │  ESPACIO activar/desactivar  │  ENTER confirmar\n\n"
  for i in "${!NAMES[@]}"; do
    local box="[ ]"
    [ "${SEL[$i]}" = "1" ] && box="[x]"
    local line
    printf -v line "  %s  %-12s  —  %s" "$box" "${NAMES[$i]}" "${DESCS[$i]}"
    if [ "$i" = "$CUR" ]; then
      printf "\033[7m%s\033[0m\n" "$line"
    else
      printf "%s\n" "$line"
    fi
  done
  printf "\n"
}

tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null' EXIT

while true; do
  draw
  IFS= read -rsn1 key
  if [[ $key == $'\033' ]]; then
    IFS= read -rsn2 key
    case "$key" in
      '[A') [ "$CUR" -gt 0 ] && CUR=$(( CUR - 1 )) ;;
      '[B') [ "$CUR" -lt $(( COUNT - 1 )) ] && CUR=$(( CUR + 1 )) ;;
    esac
  elif [[ $key == ' ' ]]; then
    [ "${SEL[$CUR]}" = "1" ] && SEL[$CUR]=0 || SEL[$CUR]=1
  elif [[ $key == $'\n' || $key == '' ]]; then
    break
  fi
done

trap - EXIT
tput cnorm 2>/dev/null
clear

echo "→ Guardando configuración..."
mkdir -p "$(dirname "$CONF_FILE")"
{
  for i in "${!VARS[@]}"; do
    echo "${VARS[$i]}=${SEL[$i]}"
  done
} > "$CONF_FILE"
echo "  ✓ $CONF_FILE"

echo "→ Instalando status.sh..."
mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR/status.sh" "$TARGET_DIR/status.sh"
chmod +x "$TARGET_DIR/status.sh"
echo "  ✓ $TARGET_DIR/status.sh"

echo "→ Configurando settings.json..."
STATUS_CMD="$TARGET_DIR/status.sh"
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi
UPDATED=$(jq --arg cmd "$STATUS_CMD" \
  '. + {"statusLine": {"type": "command", "command": $cmd}}' \
  "$SETTINGS")
echo "$UPDATED" > "$SETTINGS"
echo "  ✓ statusLine configurado en $SETTINGS"

echo ""
echo "✅ Listo. Reiniciá Claude Code para ver el nuevo statusline."

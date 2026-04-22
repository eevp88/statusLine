#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/scripts"
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

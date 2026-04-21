#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$REPO_DIR/commands/frontend"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Frontend Skills — Instalador         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

echo "¿Cómo quieres instalar las skills?"
echo ""
echo "  1) Global   → disponibles en todos tus proyectos (~/.claude/commands/frontend)"
echo "  2) Local    → solo en el proyecto actual (.claude/commands/frontend)"
echo ""
read -rp "Elige una opción [1/2]: " OPTION

case "$OPTION" in
  1)
    TARGET_DIR="$HOME/.claude/commands/frontend"
    INSTALL_TYPE="global"
    ;;
  2)
    TARGET_DIR="$(pwd)/.claude/commands/frontend"
    INSTALL_TYPE="local"
    ;;
  *)
    echo "Opción inválida. Saliendo."
    exit 1
    ;;
esac

echo ""
echo "¿Cómo quieres instalarlas?"
echo ""
echo "  1) Symlink  → se actualizan automáticamente al hacer git pull en este repo"
echo "  2) Copia    → copia estática, actualización manual"
echo ""
read -rp "Elige una opción [1/2]: " METHOD

if [ -d "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
  echo ""
  echo -e "${YELLOW}Ya existe una instalación en: $TARGET_DIR${NC}"
  read -rp "¿Reemplazar? [s/N]: " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
    echo "Instalación cancelada."
    exit 0
  fi
  rm -rf "$TARGET_DIR"
fi

mkdir -p "$(dirname "$TARGET_DIR")"

case "$METHOD" in
  1)
    ln -s "$COMMANDS_DIR" "$TARGET_DIR"
    echo ""
    echo -e "${GREEN}✓ Symlink creado ($INSTALL_TYPE):${NC}"
    echo "  $TARGET_DIR → $COMMANDS_DIR"
    ;;
  2)
    cp -r "$COMMANDS_DIR" "$TARGET_DIR"
    echo ""
    echo -e "${GREEN}✓ Archivos copiados ($INSTALL_TYPE):${NC}"
    echo "  $TARGET_DIR"
    ;;
  *)
    echo "Opción inválida. Saliendo."
    exit 1
    ;;
esac

echo ""
echo "Skills instaladas:"
for file in "$COMMANDS_DIR"/*.md; do
  name=$(basename "$file" .md)
  echo -e "  ${CYAN}/frontend:${name}${NC}"
done

echo ""
echo -e "${GREEN}¡Listo! Puedes usar las skills desde cualquier conversación con Claude Code.${NC}"
echo ""

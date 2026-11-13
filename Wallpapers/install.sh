#!/usr/bin/env bash
# Instala os wallpapers do Windows Classic.
# Uso: ./install.sh          -> instala para o usuário (~/.local/share/wallpapers)
#      sudo ./install.sh     -> instala para o sistema (/usr/share/wallpapers)
set -euo pipefail
cd "$(dirname "$0")"
if [ "$(id -u)" -eq 0 ]; then
    DEST=/usr/share/wallpapers/windows-classic
else
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers/windows-classic"
fi
mkdir -p "$DEST/Tiles"
install -m644 ./*.jpg ./*.png "$DEST/"
install -m644 Tiles/*.png "$DEST/Tiles/"
echo "Wallpapers instalados em: $DEST"

#!/usr/bin/env bash
# Configura as fontes do tema Windows Classic (Noto Sans).
#
# Uso: ./install.sh          -> usuário atual (~/.config/fontconfig/conf.d)
#      sudo ./install.sh     -> sistema (/etc/fonts/conf.d)
set -euo pipefail
cd "$(dirname "$0")"

if [ "$(fc-match -f '%{family[0]}' 'Noto Sans')" != 'Noto Sans' ]; then
    echo "A fonte Noto Sans não está instalada. No Arch Linux:" >&2
    echo "    sudo pacman -S --needed noto-fonts" >&2
    exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    DEST=/etc/fonts/conf.d
else
    DEST="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig/conf.d"
fi
mkdir -p "$DEST"
install -m644 60-windows-classic.conf "$DEST/"
fc-cache -f >/dev/null

echo "Configuração instalada em $DEST/60-windows-classic.conf"
for f in Tahoma "MS Sans Serif" "MS Shell Dlg"; do
    printf '  %-14s -> %s\n' "$f" "$(fc-match -f '%{family[0]}' "$f")"
done

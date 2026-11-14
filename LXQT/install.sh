#!/usr/bin/env bash
# Instala o tema LXQt "windows-classic" e a paleta de cores.
#
# Uso:
#   sudo ./install.sh     sistema: /usr/share/lxqt/{themes,palettes},
#                         menu Iniciar em /etc/xdg/menus e /usr/share/windows-classic
#   ./install.sh          usuário: ~/.local/share/lxqt/{themes,palettes},
#                         ~/.config/menus e ~/.local/share/windows-classic
#
# Para empacotar: DESTDIR=/tmp/pkg ./install.sh --system
# Depois, para ativar no seu usuário: ./apply.sh (veja o README)
set -euo pipefail
cd "$(dirname "$0")"

THEME=windows-classic
if [ "$(id -u)" -eq 0 ] || [ "${1:-}" = "--system" ]; then
    BASE="${DESTDIR:-}/usr/share/lxqt"
    MENUS="${DESTDIR:-}/etc/xdg/menus"
    SHARE=/usr/share/windows-classic          # caminho final (sem DESTDIR)
else
    BASE="${XDG_DATA_HOME:-$HOME/.local/share}/lxqt"
    MENUS="${XDG_CONFIG_HOME:-$HOME/.config}/menus"
    SHARE="${XDG_DATA_HOME:-$HOME/.local/share}/windows-classic"
fi
DSHARE="${DESTDIR:-}$SHARE"

mkdir -p "$BASE/themes" "$BASE/palettes"
rm -rf "${BASE:?}/themes/$THEME"
rm -rf "$BASE/themes/Windows-Classic" "$BASE/palettes/Windows-Classic"   # nome antigo (maiúsculo)
cp -r "$THEME" "$BASE/themes/"
install -m644 "palettes/$THEME" "$BASE/palettes/$THEME"

# Menu Iniciar no formato do XP
rm -rf "$DSHARE" "$(dirname "$DSHARE")/Windows-Classic"   # nome antigo (maiúsculo)
mkdir -p "$DSHARE/applications" "$DSHARE/desktop-directories" "$MENUS"
install -m755 menu/windows-classic-open-folder "$DSHARE/"
for f in menu/applications/*.desktop; do
    sed "s|@LIBDIR@|$SHARE|g" "$f" > "$DSHARE/applications/$(basename "$f")"
done
install -m644 menu/desktop-directories/*.directory "$DSHARE/desktop-directories/"
sed -e "s|@APPDIR@|$SHARE/applications|" -e "s|@DIRDIR@|$SHARE/desktop-directories|" \
    menu/windows-classic-applications.menu > "$MENUS/windows-classic-applications.menu"

echo "Tema instalado em:   $BASE/themes/$THEME"
echo "Paleta instalada em: $BASE/palettes/$THEME"
echo "Menu Iniciar em:     $MENUS/windows-classic-applications.menu"

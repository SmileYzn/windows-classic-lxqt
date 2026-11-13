#!/usr/bin/env bash
# Instala o tema SDDM "windows-classic" (tela de logon clássica do XP).
#
# Uso:
#   sudo ./install.sh            instala em /usr/share/sddm/themes
#   sudo ./install.sh --enable   instala e ativa: cria /etc/sddm.conf.d/windows-classic.conf
#                                (tema e cursor Windows-Classic); vale no próximo boot
#                                ou após "sudo systemctl restart sddm"
#   ./install.sh                 instala em ~/.local/share/sddm/themes, só para testar
#                                com o sddm-greeter-qt6 --test-mode (o SDDM não lê de lá)
#   DESTDIR=/raiz/falsa ./install.sh --system [--enable]
#                                instala os caminhos do sistema numa raiz falsa
set -euo pipefail
cd "$(dirname "$0")"

THEME=windows-classic
CURSORS=Windows-Classic
ENABLE=0
SYSTEM=0
[ "$(id -u)" -eq 0 ] && SYSTEM=1
for arg in "$@"; do
    case $arg in
        --enable) ENABLE=1 ;;
        --system) SYSTEM=1 ;;
        *) echo "Opção desconhecida: $arg" >&2; exit 1 ;;
    esac
done

if [ "$SYSTEM" -eq 1 ]; then
    ROOT="${DESTDIR:-}"
    DEST="$ROOT/usr/share/sddm/themes/$THEME"
else
    ROOT=""
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/sddm/themes/$THEME"
fi

rm -rf "$DEST"
mkdir -p "$DEST/images"
install -m644 "$THEME"/*.qml "$THEME"/qmldir "$THEME"/metadata.desktop \
    "$THEME"/theme.conf "$THEME"/preview.png "$DEST/"
install -m644 "$THEME"/images/*.png "$DEST/images/"
echo "Tema instalado em: $DEST"

if [ "$SYSTEM" -eq 0 ]; then
    echo "Para testar sem sair da sessão:"
    echo "  sddm-greeter-qt6 --test-mode --theme \"$DEST\""
    [ "$ENABLE" -eq 1 ] && echo "--enable só funciona com sudo (ou --system)." >&2
    exit 0
fi

[ "$ENABLE" -eq 1 ] || exit 0

CONF_DIR="$ROOT/etc/sddm.conf.d"
CONF="$CONF_DIR/windows-classic.conf"
mkdir -p "$CONF_DIR"
if [ -e "$CONF" ]; then
    cp -a "$CONF" "$CONF.bak.$(date +%Y%m%d%H%M%S)"
fi
{
    echo "# Criado por windows-classic-lxqt/SDDM/install.sh"
    echo "[Theme]"
    echo "Current=$THEME"
    # Cursor do XP na tela de logon, se o tema de cursores estiver instalado
    if [ -d "$ROOT/usr/share/icons/$CURSORS/cursors" ]; then
        echo "CursorTheme=$CURSORS"
        echo "CursorSize=32"
    fi
} > "$CONF"
echo "Tema ativado em: $CONF"
grep -q '^CursorTheme' "$CONF" || \
    echo "Aviso: cursores $CURSORS não encontrados; rode antes: sudo ../Cursors/install.sh"

# O /etc/sddm.conf tem prioridade sobre o conf.d
if [ -f "$ROOT/etc/sddm.conf" ] && grep -q '^[[:space:]]*Current[[:space:]]*=' "$ROOT/etc/sddm.conf"; then
    echo "Aviso: /etc/sddm.conf também define Current= e tem prioridade; remova essa linha."
fi
echo "Vale no próximo boot, ou após: sudo systemctl restart sddm (encerra a sessão gráfica!)"

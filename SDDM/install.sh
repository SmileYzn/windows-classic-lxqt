#!/usr/bin/env bash
# Instala o tema SDDM "windows-classic" (tela de logon clássica do XP).
#
# Uso:
#   sudo ./install.sh            instala em /usr/share/sddm/themes
#   sudo ./install.sh --enable   instala e ativa: cria /etc/sddm.conf.d/windows-classic.conf
#                                (tema, cursor windows-classic e o script
#                                windows-classic-xsetup, que aplica na tela de logon a
#                                resolução salva no LXQt e o cursor do fundo); vale no
#                                próximo boot ou após "sudo systemctl restart sddm"
#   ./install.sh                 instala em ~/.local/share/sddm/themes, só para testar
#                                com o sddm-greeter-qt6 --test-mode (o SDDM não lê de lá)
#   DESTDIR=/raiz/falsa ./install.sh --system [--enable]
#                                instala os caminhos do sistema numa raiz falsa
set -euo pipefail
cd "$(dirname "$0")"

THEME=windows-classic
CURSORS=windows-classic
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

rm -rf "$DEST" "$(dirname "$DEST")/Windows-Classic"   # nome antigo (maiúsculo)
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

# Preparação da tela antes do logon: resolução do LXQt e cursor do fundo
XSETUP=/usr/share/sddm/scripts/windows-classic-xsetup
mkdir -p "$ROOT$(dirname "$XSETUP")"
install -m755 windows-classic-xsetup "$ROOT$XSETUP"

CONF_DIR="$ROOT/etc/sddm.conf.d"
CONF="$CONF_DIR/windows-classic.conf"
rm -f "$CONF_DIR/Windows-Classic.conf"   # nome antigo (maiúsculo)
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
    echo
    echo "[X11]"
    echo "# Roda o Xsetup do SDDM e aplica a resolução salva no LXQt pelo último"
    echo "# usuário e o cursor do fundo (ver windows-classic-xsetup)"
    echo "DisplayCommand=$XSETUP"
} > "$CONF"
echo "Tema ativado em: $CONF"
grep -q '^CursorTheme' "$CONF" || \
    echo "Aviso: cursores $CURSORS não encontrados; rode antes: sudo ../Cursors/install.sh"

# O /etc/sddm.conf tem prioridade sobre o conf.d
if [ -f "$ROOT/etc/sddm.conf" ] && grep -q '^[[:space:]]*Current[[:space:]]*=' "$ROOT/etc/sddm.conf"; then
    echo "Aviso: /etc/sddm.conf também define Current= e tem prioridade; remova essa linha."
fi
echo "Vale no próximo boot, ou após: sudo systemctl restart sddm (encerra a sessão gráfica!)"

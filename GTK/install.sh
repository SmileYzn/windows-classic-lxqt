#!/usr/bin/env bash
# Instala o tema GTK "Windows-Classic" (GTK 3 e GTK 4/libadwaita).
#
# O tema fica na mesma pasta do tema do Openbox (themes/Windows-Classic):
# este script só troca as subpastas do GTK e não mexe em openbox-3.
#
# Uso:
#   ./install.sh                instala em ~/.local/share/themes
#   ./install.sh --apply        instala e ativa no usuário (com backup):
#                               gtk-theme-name em ~/.config/gtk-3.0/settings.ini e
#                               ~/.config/gtk-4.0/settings.ini, e um @import do tema
#                               em ~/.config/gtk-4.0/gtk.css (os apps libadwaita só
#                               leem o tema por esse arquivo)
#   sudo ./install.sh           instala em /usr/share/themes
#   sudo ./install.sh --default instala e torna o tema o padrão do sistema:
#                               gtk-theme-name em /etc/xdg/gtk-3.0/settings.ini e
#                               /etc/xdg/gtk-4.0/settings.ini (vale para quem não
#                               escolheu outro tema; não alcança o libadwaita)
#   DESTDIR=/raiz/falsa ./install.sh --system [--default]
#                               instala os caminhos do sistema numa raiz falsa
set -euo pipefail
cd "$(dirname "$0")"

THEME=Windows-Classic
APPLY=0
DEFAULT=0
SYSTEM=0
[ "$(id -u)" -eq 0 ] && SYSTEM=1
for arg in "$@"; do
    case $arg in
        --apply) APPLY=1 ;;
        --default) DEFAULT=1 ;;
        --system) SYSTEM=1 ;;
        *) echo "Opção desconhecida: $arg" >&2; exit 1 ;;
    esac
done

if [ "$SYSTEM" -eq 1 ]; then
    ROOT="${DESTDIR:-}"
    DEST="$ROOT/usr/share/themes/$THEME"
else
    ROOT=""
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/themes/$THEME"
fi

mkdir -p "$DEST"
rm -rf "$DEST/gtk-3.0" "$DEST/gtk-3.22" "$DEST/gtk-3.24" "$DEST/gtk-4.0"
cp -r "$THEME/gtk-3.0" "$THEME/gtk-4.0" "$DEST/"
ln -s gtk-3.0 "$DEST/gtk-3.22"
ln -s gtk-3.0 "$DEST/gtk-3.24"
install -m644 "$THEME/index.theme" "$DEST/index.theme"
echo "Tema GTK instalado em: $DEST"

# set_key <arquivo> <chave> <valor>: grava a chave na seção [Settings], com backup
set_key() {
    python3 -I - "$1" "$2" "$3" <<'PY'
import os, re, shutil, sys, time
path, key, value = sys.argv[1:4]
text = open(path).read() if os.path.exists(path) else ""
if text:
    shutil.copy2(path, path + ".bak." + time.strftime("%Y%m%d%H%M%S"))
m = re.search(r"(?m)^\[Settings\][ \t]*\n", text)
if m is None:
    text = text.rstrip("\n") + ("\n\n" if text else "") + "[Settings]\n%s=%s\n" % (key, value)
else:
    end = re.search(r"(?m)^\[", text[m.end():])
    end = m.end() + end.start() if end else len(text)
    body = text[m.end():end]
    line = re.compile(r"(?m)^[ \t]*%s[ \t]*=.*$" % re.escape(key))
    if line.search(body):
        body = line.sub("%s=%s" % (key, value), body, count=1)
    else:
        body = body.rstrip("\n") + ("\n" if body.strip() else "") + "%s=%s\n" % (key, value)
        if end < len(text):
            body += "\n"
    text = text[:m.end()] + body + text[end:]
os.makedirs(os.path.dirname(path), exist_ok=True)
open(path, "w").write(text)
PY
}

if [ "$DEFAULT" -eq 1 ]; then
    if [ "$SYSTEM" -eq 0 ]; then
        echo "--default só funciona com sudo (ou --system)." >&2
        exit 1
    fi
    for v in 3.0 4.0; do
        set_key "$ROOT/etc/xdg/gtk-$v/settings.ini" gtk-theme-name "$THEME"
        echo "Tema padrão do sistema: $ROOT/etc/xdg/gtk-$v/settings.ini"
    done
fi

if [ "$APPLY" -eq 1 ]; then
    if [ "$SYSTEM" -eq 1 ]; then
        echo "--apply deve ser executado como usuário comum (sem sudo)." >&2
        exit 1
    fi
    CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
    for v in 3.0 4.0; do
        set_key "$CFG/gtk-$v/settings.ini" gtk-theme-name "$THEME"
        echo "Tema ativado em: $CFG/gtk-$v/settings.ini"
    done
    # Apps libadwaita ignoram gtk-theme-name: só carregam ~/.config/gtk-4.0/gtk.css.
    # Uma linha marcada importa o gtk.css do tema; o resto do arquivo fica como está.
    python3 -I - "$CFG/gtk-4.0/gtk.css" "$DEST/gtk-4.0/gtk.css" <<'PY'
import os, shutil, sys, time
path, theme_css = sys.argv[1:3]
MARK = "/* windows-classic-lxqt: tema GTK 4 */"
line = '@import url("file://%s"); %s' % (theme_css, MARK)
text = open(path).read() if os.path.exists(path) else ""
if text:
    shutil.copy2(path, path + ".bak." + time.strftime("%Y%m%d%H%M%S"))
rest = [l for l in text.splitlines() if MARK not in l]
os.makedirs(os.path.dirname(path), exist_ok=True)
open(path, "w").write("\n".join([line] + rest).rstrip("\n") + "\n")
PY
    echo "Tema GTK 4/libadwaita ativado em: $CFG/gtk-4.0/gtk.css"
    echo "Vale para os apps abertos daqui em diante."
fi

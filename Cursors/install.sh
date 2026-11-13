#!/usr/bin/env bash
# Instala o tema de cursores "Windows-Classic".
#
# Uso:
#   ./install.sh            instala em ~/.local/share/icons
#   sudo ./install.sh       instala em /usr/share/icons
#   ./install.sh --apply    instala e ativa no LXQt (tamanho 32, como no XP);
#                           vale a partir do próximo login
set -euo pipefail
cd "$(dirname "$0")"

THEME=Windows-Classic
SIZE=32
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

if [ "$(id -u)" -eq 0 ]; then
    DEST=/usr/share/icons
else
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
fi
mkdir -p "$DEST/$THEME"
rm -rf "$DEST/$THEME/cursors"
cp -a "$THEME/cursors" "$THEME/index.theme" "$DEST/$THEME/"
echo "Cursores instalados em: $DEST/$THEME"

[ "$APPLY" -eq 1 ] || exit 0
if [ "$(id -u)" -eq 0 ]; then
    echo "--apply deve ser executado como usuário comum (sem sudo)." >&2
    exit 1
fi

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

# LXQt: [Mouse] cursor_theme / cursor_size em session.conf
mkdir -p "$CFG/lxqt"
python3 -I - "$CFG/lxqt/session.conf" "$THEME" "$SIZE" <<'PY'
import os, re, sys
path, theme, size = sys.argv[1:4]
text = open(path).read() if os.path.exists(path) else ""
values = {"cursor_theme": theme, "cursor_size": size}
m = re.search(r"(?m)^\[Mouse\][ \t]*\n", text)
if m is None:
    text = text.rstrip("\n") + ("\n\n" if text else "") + "[Mouse]\n" + \
        "".join(f"{k}={v}\n" for k, v in values.items())
else:
    end = re.search(r"(?m)^\[", text[m.end():])
    end = m.end() + end.start() if end else len(text)
    lines = text[m.end():end].strip("\n").splitlines()
    for k, v in values.items():
        idx = [i for i, l in enumerate(lines) if re.match(rf"{k}[ \t]*=", l)]
        if idx:
            lines[idx[0]] = f"{k}={v}"
        else:
            lines.append(f"{k}={v}")
    body = "\n".join(lines) + "\n" + ("\n" if end < len(text) else "")
    text = text[:m.end()] + body + text[end:]
open(path, "w").write(text)
PY

# Tema padrão do X11 (apps fora do LXQt e a janela raiz)
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nInherits=%s\n' "$THEME" > "$HOME/.icons/default/index.theme"

echo "Cursor ativado (tema $THEME, tamanho $SIZE). Faça logout/login para aplicar."

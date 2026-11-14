#!/usr/bin/env bash
# Ativa o tema Windows Classic no LXQt do usuário atual (rode sem sudo,
# depois de instalar o tema com install.sh).
#
#   ./apply.sh           tema, paleta Clássica, estilo Qt "Windows" e
#                        fonte Noto Sans 9 (~/.config/lxqt/lxqt.conf)
#   ./apply.sh --panel   também monta o painel no layout do XP
#                        (~/.config/lxqt/panel.conf): Iniciar, Inicialização
#                        rápida, tarefas e bandeja com relógio, 28 px
#
# Os arquivos alterados ganham um backup (*.bak.AAAAMMDDhhmmss).
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Rode sem sudo: a configuração é do seu usuário." >&2
    exit 1
fi

PANEL=0
[ "${1:-}" = "--panel" ] && PANEL=1
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/lxqt"
STAMP=$(date +%Y%m%d%H%M%S)
mkdir -p "$CFG"
for f in lxqt.conf panel.conf; do
    [ -f "$CFG/$f" ] && cp "$CFG/$f" "$CFG/$f.bak.$STAMP"
done

# Texto do botão Iniciar conforme o idioma
case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in
    pt*) START=Iniciar ;;
    es*) START=Inicio ;;
    *)   START=Start ;;
esac

python3 -I - "$CFG" "$PANEL" "$START" <<'PY'
import os, re, sys

cfg, panel, start = sys.argv[1], sys.argv[2] == "1", sys.argv[3]

def set_keys(path, section, values):
    """Define chaves numa seção de um .conf do Qt (QSettings), sem mexer no resto."""
    text = open(path).read() if os.path.exists(path) else ""
    head = re.search(rf"(?m)^\[{re.escape(section)}\][ \t]*\n?", text)
    if head is None:
        text = text.rstrip("\n") + ("\n\n" if text.strip() else "") + f"[{section}]\n"
        head = re.search(rf"(?m)^\[{re.escape(section)}\][ \t]*\n?", text)
    nxt = re.search(r"(?m)^\[", text[head.end():])
    end = head.end() + nxt.start() if nxt else len(text)
    lines = text[head.end():end].strip("\n").splitlines()
    for k, v in values.items():
        idx = [i for i, l in enumerate(lines) if l.split("=", 1)[0].strip() == k]
        if idx:
            lines[idx[0]] = f"{k}={v}"
        else:
            lines.append(f"{k}={v}")
    body = "\n".join(lines) + "\n" + ("\n" if end < len(text) else "")
    open(path, "w").write(text[:head.end()] + body + text[end:])

lxqt = os.path.join(cfg, "lxqt.conf")
set_keys(lxqt, "General", {"theme": "windows-classic"})
set_keys(lxqt, "Palette", {
    "base_color": "#ffffff", "highlight_color": "#0a246a",
    "highlighted_text_color": "#ffffff", "link_color": "#0000ff",
    "link_visited_color": "#800080", "text_color": "#000000",
    "tooltip_base_color": "#ffffe1", "tooltip_text_color": "#000000",
    "window_color": "#d4d0c8", "window_text_color": "#000000",
})
set_keys(lxqt, "Qt", {
    "style": "Windows",
    "font": '"Noto Sans,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"',
})
print("Tema, paleta, estilo e fonte ativados em", lxqt)

if panel:
    # Caminho completo: o painel não procura o nome em ~/.config/menus
    menu_file = "/etc/xdg/menus/windows-classic-applications.menu"
    user_menu = os.path.join(os.path.dirname(cfg), "menus", "windows-classic-applications.menu")
    if not os.path.exists(menu_file) and os.path.exists(user_menu):
        menu_file = user_menu
    p = os.path.join(cfg, "panel.conf")
    if not os.path.exists(p):
        open(p, "w").write("[General]\n__userfile__=true\n")
    set_keys(p, "panel1", {
        "plugins": "mainmenu, quicklaunch, taskbar, statusnotifier, tray, volume, worldclock",
        "position": "Bottom", "panelSize": "28", "iconSize": "16", "lineCount": "1",
        "alignment": "-1", "width": "100", "width-percent": "true",
    })
    # O lxqt-panel 2.x só carrega a seção que tiver "type="
    # Menu no formato do XP, sem o campo de busca
    set_keys(p, "mainmenu", {"type": "mainmenu", "showText": "true", "text": start,
                             "ownIcon": "false", "alignment": "Left",
                             "menu_file": menu_file,
                             "filterMenu": "false", "filterShow": "false"})
    set_keys(p, "quicklaunch", {"type": "quicklaunch", "alignment": "Left"})
    set_keys(p, "taskbar", {"type": "taskbar", "alignment": "Left", "buttonWidth": "160",
                            "showOnlyOneDesktopTasks": "true", "groupingEnabled": "false"})
    for name in ("statusnotifier", "tray", "volume", "worldclock"):
        set_keys(p, name, {"type": name, "alignment": "Right"})
    print("Painel no layout do XP em", p)
PY

if [ "$PANEL" -eq 1 ] && pgrep -x lxqt-panel >/dev/null; then
    echo "Reinicie o painel para aplicar:  pkill -x lxqt-panel   (a sessão o abre de novo)"
fi

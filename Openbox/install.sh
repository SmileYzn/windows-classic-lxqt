#!/usr/bin/env bash
# Instala o tema Openbox "windows-classic".
#
# Uso:
#   ./install.sh            instala em ~/.local/share/themes
#   sudo ./install.sh       instala em /usr/share/themes
#   ./install.sh --apply    instala e ativa (tema, fontes Noto Sans e ordem
#                           dos botões) em ~/.config/openbox/rc.xml,
#                           com backup
set -euo pipefail
cd "$(dirname "$0")"

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

if [ "$(id -u)" -eq 0 ]; then
    DEST=/usr/share/themes
else
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
fi
mkdir -p "$DEST"
rm -rf "$DEST/windows-classic/openbox-3"
# Nome antigo (maiúsculo): tira só o openbox-3; a pasta some quando o GTK também sair
rm -rf "$DEST/Windows-Classic/openbox-3"
rmdir "$DEST/Windows-Classic" 2>/dev/null || true
mkdir -p "$DEST/windows-classic"
cp -r windows-classic/openbox-3 "$DEST/windows-classic/"
echo "Tema instalado em: $DEST/windows-classic"

[ "$APPLY" -eq 1 ] || exit 0

if [ "$(id -u)" -eq 0 ]; then
    echo "--apply deve ser executado como usuário comum (sem sudo)." >&2
    exit 1
fi

CFG="${XDG_CONFIG_HOME:-$HOME/.config}/openbox"
mkdir -p "$CFG"
# O Openbox lê rc.xml; versões antigas do LXQt usavam lxqt-rc.xml.
[ -f "$CFG/rc.xml" ] || cp /etc/xdg/openbox/rc.xml "$CFG/rc.xml"
for RC in "$CFG/rc.xml" "$CFG/lxqt-rc.xml"; do
[ -f "$RC" ] || continue
cp "$RC" "$RC.bak.$(date +%Y%m%d%H%M%S)"

python3 -I - "$RC" <<'PY'
import sys, xml.etree.ElementTree as ET
NS = "http://openbox.org/3.4/rc"
ET.register_namespace("", NS)
q = lambda t: f"{{{NS}}}{t}"
path = sys.argv[1]
parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
tree = ET.parse(path, parser)
theme = tree.getroot().find(q("theme"))

def child(parent, tag):
    el = parent.find(q(tag))
    if el is None:
        el = ET.SubElement(parent, q(tag))
    return el

child(theme, "name").text = "windows-classic"
# Ícone, título, minimizar, maximizar, fechar — igual ao Windows
child(theme, "titleLayout").text = "NLIMC"

# Fonte: Noto Sans (no XP era Tahoma 8). No título usamos 9: o Openbox
# calcula a altura da barra e dos botões a partir da fonte, e com Noto Sans
# Bold 9 (mais padding.height 1) a barra fica com 18 px e os botões com
# 14 px, como no XP.
fonts = {
    "ActiveWindow": ("Bold", 9), "InactiveWindow": ("Bold", 9),
    "MenuHeader": ("Normal", 8), "MenuItem": ("Normal", 8),
    "ActiveOnScreenDisplay": ("Normal", 8), "InactiveOnScreenDisplay": ("Normal", 8),
}
for place, (weight, size) in fonts.items():
    font = next((f for f in theme.findall(q("font")) if f.get("place") == place), None)
    if font is None:
        font = ET.SubElement(theme, q("font"), place=place)
    child(font, "name").text = "Noto Sans"
    child(font, "size").text = str(size)
    child(font, "weight").text = weight
    child(font, "slant").text = "Normal"

ET.indent(tree, space="  ")
tree.write(path, encoding="UTF-8", xml_declaration=True)
PY
echo "Tema ativado em $RC (backup criado ao lado)."
done

openbox --reconfigure 2>/dev/null || true

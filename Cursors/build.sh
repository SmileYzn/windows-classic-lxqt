#!/usr/bin/env bash
# Gera o tema de cursores a partir da mídia de instalação do Windows XP:
# extrai USER32.DL_ e OLE32.DL_ da pasta I386, lê os recursos de cursor
# e monta os arquivos Xcursor (32 e 64 px) com o xcursorgen.
#
# Uso: ./build.sh /caminho/para/I386
# Requer: cabextract, 7zip, imagemagick, xorg-xcursorgen, python3
set -euo pipefail

I386="${1:?Uso: $0 /caminho/para/I386}"
THEME="$(cd "$(dirname "$0")" && pwd)/Windows-Classic"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for dll in user32 ole32; do
    cabextract -q -d "$TMP" "$I386/${dll^^}.DL_"
    mkdir -p "$TMP/$dll"
    7z x -y -o"$TMP/$dll" "$TMP/$dll.dll" '.rsrc/CURSOR/*' '.rsrc/GROUP_CURSOR/*' >/dev/null
done

rm -rf "$THEME/cursors" "$THEME/build/png" "$THEME"/build/*.in
python3 -I -B "$THEME/build/tools/build_cursors.py" \
    "$TMP/user32/.rsrc" "$TMP/ole32/.rsrc" "$THEME"
rm -f "$THEME/build/tools/raw"

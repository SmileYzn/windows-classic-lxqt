#!/usr/bin/env bash
# Gera as imagens do tema SDDM "windows-classic" a partir da mídia do XP.
#
#  - I386/MSGINA.DL_ (a tela de logon do XP):
#      banner.png        bitmap 107: faixa "Windows XP Professional" grande (411x88),
#                        usada no diálogo "Fazer logon no Windows"
#      banner-small.png  bitmap 101: faixa pequena (411x72), usada no
#                        diálogo "Desligar o Windows"
#      bar.png           bitmap 103: barra colorida (411x5) que fica sob a faixa
#                        e corre enquanto o logon é processado
#      shutdown.png      ícone 22 (computador) do diálogo de desligar, 32x32
#  - I386/USER32.DL_:
#      information.png   ícone 104 (informação), 32x32: mensagem de falha no logon
#      warning.png       ícone 101 (aviso), 16x16: balão do Caps Lock
#
# Uso: ./build.sh /caminho/para/I386
# Requer: cabextract, 7zip, icoutils, imagemagick
set -euo pipefail

I386="${1:?Uso: $0 /caminho/para/I386}"
OUT="$(cd "$(dirname "$0")" && pwd)/windows-classic/images"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

# --- msgina.dll -----------------------------------------------------------
cabextract -q -d "$TMP" "$I386/MSGINA.DL_"
7z x -y -o"$TMP/msgina" "$TMP/msgina.dll" \
    '.rsrc/BITMAP/101.bmp' '.rsrc/BITMAP/103.bmp' '.rsrc/BITMAP/107.bmp' >/dev/null
BMP="$TMP/msgina/.rsrc/BITMAP"
# Os bitmaps têm 413 px, mas as 2 últimas colunas são lixo: o diálogo tem
# 274 DLU = 411 px de largura e mostra só as primeiras 411 colunas.
magick "$BMP/107.bmp" -crop 411x88+0+0 +repage "PNG24:$OUT/banner.png"
magick "$BMP/101.bmp" -crop 411x72+0+0 +repage "PNG24:$OUT/banner-small.png"
magick "$BMP/103.bmp" -crop 411x5+0+0 +repage "PNG24:$OUT/bar.png"

# extrai_icone <dll> <grupo> <tamanho> <saída>: pega a melhor profundidade de cor
extrai_icone() {
    local dll=$1 group=$2 size=$3 out=$4 dir
    dir="$TMP/ico-$(basename "$dll")-$group"
    mkdir -p "$dir"
    wrestool -x -t14 -n "$group" "$dll" > "$dir/icon.ico"
    icotool -x -o "$dir" "$dir/icon.ico"
    # nomes: icon_<índice>_<L>x<A>x<bits>.png; a maior profundidade fica por último
    local best
    best=$(ls "$dir"/*_"${size}x${size}"x*.png | sort -t x -k3 -n | tail -n 1)
    magick "$best" "PNG32:$out"
}

extrai_icone "$TMP/msgina.dll" 22 32 "$OUT/shutdown.png"

# --- user32.dll -----------------------------------------------------------
cabextract -q -d "$TMP" "$I386/USER32.DL_"
extrai_icone "$TMP/user32.dll" 104 32 "$OUT/information.png"
extrai_icone "$TMP/user32.dll" 101 16 "$OUT/warning.png"

echo "Imagens geradas em: $OUT"
ls -1 "$OUT"

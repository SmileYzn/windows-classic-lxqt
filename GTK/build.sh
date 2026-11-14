#!/usr/bin/env bash
# Gera as imagens do tema GTK "windows-classic" que vêm da mídia do XP ou
# que são desenhadas aqui. O resto dos assets veio do tema Win2k, já
# convertido para as cores do XP (veja tools/xp-dkshadow.py e o README).
#
#  - Da mídia do Windows XP (I386/BROWSEUI.DL_, bitmap 306: 41 quadros de 22x22):
#      gtk-3.0/assets/status_badge.png      logotipo parado (quadro 0) no fim da barra
#                                           de menus do Thunar, como no Explorer clássico
#      gtk-3.0/assets/throbber/throbber_fN  globo girando (quadros 1-40) durante o carregamento
#  - Desenhadas aqui:
#      gtk-3.0/scrollbar/trough.png         calha da barra de rolagem: xadrez 2x2 de
#                                           ButtonHilight (#FFFFFF) e Scrollbar (#D4D0C8)
#      gtk-3.0/assets/menu-check*.png       marca dos itens de menu (DFCS_MENUCHECK, 7x7)
#      gtk-3.0/assets/menu-radio*.png       marcador de opção no menu (DFCS_MENUBULLET, 6x6)
#                                           normal (preto), -selected (branco, sobre a
#                                           seleção) e -insensitive (cinza com relevo branco)
#      gtk-4.0/assets/menu-*.png            os mesmos glifos, copiados para o GTK 4
#
# Uso: ./build.sh /caminho/para/I386
# Requer: cabextract, 7zip, imagemagick
set -euo pipefail

I386="${1:?Uso: $0 /caminho/para/I386}"
OUT="$(cd "$(dirname "$0")" && pwd)/windows-classic/gtk-3.0"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- browseui.dll: animação do Explorer -----------------------------------
cabextract -q -d "$TMP" "$I386/BROWSEUI.DL_"
7z x -y -o"$TMP/rsrc" "$TMP/browseui.dll" '.rsrc/BITMAP/306.bmp' >/dev/null
STRIP="$TMP/rsrc/.rsrc/BITMAP/306.bmp"
mkdir -p "$OUT/assets/throbber"
magick "$STRIP" -crop 22x22+0+0 +repage "PNG24:$OUT/assets/status_badge.png"
for i in $(seq 1 40); do
    magick "$STRIP" -crop "22x22+0+$((i * 22))" +repage "PNG24:$OUT/assets/throbber/throbber_f$i.png"
done

# --- Calha da barra de rolagem ---------------------------------------------
printf '%s\n' '# ImageMagick pixel enumeration: 2,2,255,srgb' \
    '0,0: (255,255,255)' '1,0: (212,208,200)' \
    '0,1: (212,208,200)' '1,1: (255,255,255)' |
    magick txt:- "PNG24:$OUT/scrollbar/trough.png"

# --- Glifos dos itens de menu (16x16, glifo centralizado) -------------------
# glifo <saída> <cor do glifo r,g,b> <cor do relevo r,g,b ou ""> <linhas: X = glifo>
glifo() {
    local out=$1 fg=$2 hl=$3; shift 3
    local h=$# w=${#1} x0 y0 x y row txt
    x0=$(( (16 - w) / 2 )); y0=$(( (16 - h) / 2 ))
    txt="# ImageMagick pixel enumeration: 16,16,255,srgba"$'\n'
    declare -A px=()
    y=0
    for row in "$@"; do
        for ((x = 0; x < w; x++)); do
            if [ "${row:x:1}" = X ]; then
                # relevo: o mesmo glifo 1 px abaixo e à direita, por baixo
                [ -n "$hl" ] && [ -z "${px[$((x0 + x + 1)),$((y0 + y + 1))]:-}" ] && \
                    px[$((x0 + x + 1)),$((y0 + y + 1))]="$hl"
                px[$((x0 + x)),$((y0 + y))]="$fg"
            fi
        done
        y=$((y + 1))
    done
    for ((y = 0; y < 16; y++)); do
        for ((x = 0; x < 16; x++)); do
            if [ -n "${px[$x,$y]:-}" ]; then
                txt+="$x,$y: (${px[$x,$y]},255)"$'\n'
            else
                txt+="$x,$y: (0,0,0,0)"$'\n'
            fi
        done
    done
    printf '%s' "$txt" | magick txt:- "PNG32:$out"
}
CHECK=(......X .....XX X...XXX XX.XXX. XXXXX.. .XXX... ..X....)
BULLET=(..XX.. .XXXX. XXXXXX XXXXXX .XXXX. ..XX..)
for kind in check radio; do
    if [ $kind = check ]; then rows=("${CHECK[@]}"); else rows=("${BULLET[@]}"); fi
    glifo "$OUT/assets/menu-$kind.png"             0,0,0       "" "${rows[@]}"
    glifo "$OUT/assets/menu-$kind-selected.png"    255,255,255 "" "${rows[@]}"
    glifo "$OUT/assets/menu-$kind-insensitive.png" 128,128,128 255,255,255 "${rows[@]}"
done
# O gtk-4.0 é independente do gtk-3.0: os glifos vão também para os assets dele
cp "$OUT"/assets/menu-check*.png "$OUT"/assets/menu-radio*.png "$OUT/../gtk-4.0/assets/"

echo "Imagens geradas em: $OUT e $OUT/../gtk-4.0/assets"

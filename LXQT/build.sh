#!/usr/bin/env bash
# Gera as imagens do tema LXQt "windows-classic".
#
#  - Da mídia do Windows XP (I386/EXPLORER.EX_, recursos BITMAP):
#      start.png   bandeira do botão Iniciar (bitmap 176, 16x16 com alfa)
#      banner.png  faixa lateral do menu Iniciar clássico (bitmap 167,
#                  "Windows XP Professional"), sobre uma coluna preta alta
#                  para menus maiores que a faixa, como no XP
#  - Desenhados aqui, com as cores do esquema Clássico (HIVEDEF.INF):
#      button.png, button-pressed.png, frame.png, taskbar-*.png
#
# Uso: ./build.sh /caminho/para/I386
# Requer: cabextract, 7zip, imagemagick
set -euo pipefail

I386="${1:?Uso: $0 /caminho/para/I386}"
OUT="$(cd "$(dirname "$0")" && pwd)/windows-classic/images"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

# --- Recursos do explorer.exe -------------------------------------------
cabextract -q -d "$TMP" "$I386/EXPLORER.EX_"
7z x -y -o"$TMP/rsrc" "$TMP/explorer.exe" '.rsrc/BITMAP/176.bmp' '.rsrc/BITMAP/167.bmp' >/dev/null
BMP="$TMP/rsrc/.rsrc/BITMAP"

magick "$BMP/176.bmp" "PNG32:$OUT/start.png"
# Faixa de 21x233 no pé de uma coluna preta de 21x1200
magick -size 21x1200 xc:black "$BMP/167.bmp" -gravity south -composite "PNG24:$OUT/banner.png"

# --- Relevos 3D (border-image com 2 px de borda) --------------------------
# pixel <arquivo> <largura> <altura> <linhas: uma letra por pixel>
#   W #FFFFFF  F #D4D0C8  G #808080  D #404040  K #000000  T transparente
pixel() {
    local file=$1 w=$2 h=$3; shift 3
    local txt="# ImageMagick pixel enumeration: $w,$h,255,srgba"$'\n' y=0 row x c
    for row in "$@"; do
        for ((x = 0; x < w; x++)); do
            case ${row:x:1} in
                W) c="255,255,255,255" ;; F) c="212,208,200,255" ;;
                G) c="128,128,128,255" ;; D) c="64,64,64,255" ;;
                K) c="0,0,0,255" ;;
                T) c="0,0,0,0" ;;
            esac
            txt+="$x,$y: ($c)"$'\n'
        done
        y=$((y + 1))
    done
    printf '%s' "$txt" | magick txt:- "PNG32:$file"
}

# Botão (DrawFrameControl): branco/face em cima-esq., cinza-escuro/cinza embaixo-dir.
pixel "$OUT/button.png" 5 5 \
    WWWWD \
    WFFGD \
    WFFGD \
    WGGGD \
    DDDDD
# Botão pressionado
pixel "$OUT/button-pressed.png" 5 5 \
    DDDDW \
    DGGFW \
    DGFFW \
    DFFFW \
    WWWWW
# Campo de texto/lista (EDGE_SUNKEN): cinza/escuro por fora e por dentro em
# cima-esq., branco/face embaixo-dir.; miolo transparente (mostra o fundo)
pixel "$OUT/field.png" 5 5 \
    GGGGW \
    GDDFW \
    GDTFW \
    GFFFW \
    WWWWW
# Moldura de janela/menu (EDGE_RAISED): face/branco por fora, cinza/escuro por
# dentro. Miolo transparente: no QSS o miolo do border-image cobre o fundo.
pixel "$OUT/frame.png" 5 5 \
    FFFFD \
    FWWGD \
    FWTGD \
    FGGGD \
    DDDDD
# Borda da barra de tarefas (2 px) para cada posição do painel
pixel "$OUT/taskbar-bottom.png" 4 4 FFFF WWWW FFFF FFFF    # painel embaixo: borda em cima
pixel "$OUT/taskbar-top.png"    4 4 FFFF FFFF GGGG DDDD    # painel em cima: borda embaixo
pixel "$OUT/taskbar-left.png"   4 4 FFGD FFGD FFGD FFGD    # painel à esquerda: borda à direita
pixel "$OUT/taskbar-right.png"  4 4 FWFF FWFF FWFF FWFF    # painel à direita: borda à esquerda

# Seta de submenu do Classic (4x7): preta e branca (item selecionado)
pixel "$OUT/arrow.png" 4 7 DTTT DDTT DDDT DDDD DDDT DDTT DTTT
magick "$OUT/arrow.png" -fill black -colorize 100 "PNG32:$OUT/arrow.png"
magick "$OUT/arrow.png" -fill white -colorize 100 "PNG32:$OUT/arrow-selected.png"

# Botão "fechar" da barra de título (16x14, glifo X 8x7), para o Executar
# e as notificações
pixel "$OUT/close.png" 16 14 \
    WWWWWWWWWWWWWWWD \
    WFFFFFFFFFFFFFGD \
    WFFFFFFFFFFFFFGD \
    WFFFKKFFFFKKFFGD \
    WFFFFKKFFKKFFFGD \
    WFFFFFKKKKFFFFGD \
    WFFFFFFKKFFFFFGD \
    WFFFFFKKKKFFFFGD \
    WFFFFKKFFKKFFFGD \
    WFFFKKFFFFKKFFGD \
    WFFFFFFFFFFFFFGD \
    WFFFFFFFFFFFFFGD \
    WGGGGGGGGGGGGGGD \
    DDDDDDDDDDDDDDDD

ls -1 "$OUT"

#!/usr/bin/env bash
# Gera os glifos (.xbm) dos botões do tema Openbox.
#
# Os glifos são desenhados aqui em pixel art, com o tamanho e a posição
# dos botões de 16x14 px do tema Clássico do XP: X 8x7, minimizar 6x2,
# maximizar 9x9, restaurar 8x9 e seta de submenu 4x7.
#
# Uso: ./build.sh
# Requer: imagemagick
set -euo pipefail

OUT="$(cd "$(dirname "$0")" && pwd)/Windows-Classic/openbox-3"
mkdir -p "$OUT"

# xbm <arquivo> <largura> <altura> <linhas...>   ("#" = pixel aceso)
xbm() {
    local file=$1 w=$2 h=$3; shift 3
    {
        printf 'P1\n%d %d\n' "$w" "$h"
        for row in "$@"; do
            printf '%s\n' "$row" | sed 's/#/1 /g; s/\./0 /g'
        done
    } | magick pbm:- "xbm:$file"
}

# Desloca as linhas 1 px para baixo/direita (botão pressionado, como no XP)
press() { printf '%s\n' '..........'; for row in "$@"; do printf '%s\n' ".${row:0:9}"; done | head -10; }

# Glifos numa tela 10x10, para o Openbox centralizar todos do mesmo jeito.
CLOSE=(
'..........'
'.##....##.'
'..##..##..'
'...####...'
'....##....'
'...####...'
'..##..##..'
'.##....##.'
'..........'
'..........')
ICONIFY=(
'..........'
'..........'
'..........'
'..........'
'..........'
'..........'
'..........'
'.######...'
'.######...'
'..........')
MAX=(
'#########.'
'#########.'
'#.......#.'
'#.......#.'
'#.......#.'
'#.......#.'
'#.......#.'
'#.......#.'
'#########.'
'..........')
RESTORE=(
'..######..'
'..######..'
'..#....#..'
'######.#..'
'######.#..'
'#....###..'
'#....#....'
'#....#....'
'######....'
'..........')
SHADE=(
'..........'
'..........'
'..........'
'....#.....'
'...###....'
'..#####...'
'..........'
'..........'
'..........'
'..........')
UNSHADE=(
'..........'
'..........'
'..........'
'..#####...'
'...###....'
'....#.....'
'..........'
'..........'
'..........'
'..........')
DESK=(
'..........'
'..........'
'..........'
'....##....'
'...####...'
'...####...'
'....##....'
'..........'
'..........'
'..........')
DESK_ON=(
'..........'
'..........'
'...####...'
'..######..'
'..######..'
'..######..'
'..######..'
'...####...'
'..........'
'..........')

button() { # button <nome> <linhas...>
    local name=$1; shift
    xbm "$OUT/$name.xbm" 10 10 "$@"
    mapfile -t pressed < <(press "$@")
    xbm "$OUT/${name}_pressed.xbm" 10 10 "${pressed[@]}"
}

button close         "${CLOSE[@]}"
button iconify       "${ICONIFY[@]}"
button max           "${MAX[@]}"
button max_toggled   "${RESTORE[@]}"
button shade         "${SHADE[@]}"
button shade_toggled "${UNSHADE[@]}"
button desk          "${DESK[@]}"
button desk_toggled  "${DESK_ON[@]}"

# Seta de submenu
xbm "$OUT/bullet.xbm" 4 7 '#...' '##..' '###.' '####' '###.' '##..' '#...'

echo "Glifos gerados em $OUT"

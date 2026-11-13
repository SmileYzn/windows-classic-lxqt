#!/usr/bin/env python3
"""Converte a sombra escura dos relevos do Windows 2000 para a do XP Clássico.

Os assets herdados do win2k desenham a sombra escura (ButtonDkShadow) em preto
puro. No XP, o esquema Clássico usa 64 64 64 (#404040, I386/HIVEDEF.INF). O
preto também é usado em glifos (setas, marca de seleção, X de fechar) e na
moldura do botão padrão, que continuam pretos.

Regra: um pixel preto opaco que tem um vizinho (8-vizinhança) cinza #808080
(ButtonShadow) faz parte de um relevo e vira #404040. Os glifos e a moldura
preta não encostam no cinza. Exceção: se a borda inteira da imagem é preta,
ela é a moldura preta (WindowFrame) do botão padrão/pressionado e fica preta.
O script é idempotente.

Uso: xp-dkshadow.py arquivo.png [...]
Requer: imagemagick (lê e grava via formato txt do magick, sem PIL)
"""
import re
import subprocess
import sys

def load(path):
    out = subprocess.run(["magick", path, "-depth", "8", "txt:-"],
                         check=True, capture_output=True, text=True).stdout
    lines = out.splitlines()
    head = lines[0]
    w, h = map(int, re.match(r"# ImageMagick pixel enumeration: (\d+),(\d+)", head).groups())
    px = {}
    for line in lines[1:]:
        m = re.match(r"^(\d+),(\d+): \(([^)]*)\)", line)
        if not m:
            continue
        vals = [float(v.strip().rstrip("%")) for v in m.group(3).split(",")]
        if len(vals) == 3:
            vals.append(255)
        r, g, b, a = (int(round(v)) for v in vals[:4])
        px[(int(m.group(1)), int(m.group(2)))] = (r, g, b, a)
    return w, h, px


def save(path, w, h, px):
    txt = ["# ImageMagick pixel enumeration: %d,%d,255,srgba" % (w, h)]
    for y in range(h):
        for x in range(w):
            txt.append("%d,%d: (%d,%d,%d,%d)" % ((x, y) + px[(x, y)]))
    subprocess.run(["magick", "txt:-", "PNG32:" + path], input="\n".join(txt) + "\n",
                   check=True, text=True)


def convert(path):
    w, h, px = load(path)
    black = (0, 0, 0, 255)
    gray = (128, 128, 128, 255)
    ring = {(x, y) for (x, y) in px if x in (0, w - 1) or y in (0, h - 1)}
    frame = ring if all(px[p] == black for p in ring) else set()
    change = []
    for (x, y), c in px.items():
        if c != black or (x, y) in frame:
            continue
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                if px.get((x + dx, y + dy)) == gray:
                    change.append((x, y))
                    break
            else:
                continue
            break
    if change:
        for p in change:
            px[p] = (64, 64, 64, 255)
        save(path, w, h, px)
    return len(change)


if __name__ == "__main__":
    for f in sys.argv[1:]:
        n = convert(f)
        if n:
            print("%4d px  %s" % (n, f))

#!/usr/bin/env bash
# Extra opcional: relevo 3D e sombras de menu do Windows Classic via picom.
#
# - copia o shader para ~/.config/picom/windows-classic.glsl
# - no picom.conf (com backup): usa o backend "glx", ajusta a sombra para a
#   do XP e adiciona ao fim de "rules" as regras do Windows Classic (relevo
#   das janelas/menus do Openbox e sombra sob os menus). Reinstalar troca as
#   regras antigas pelas novas.
#
# Uso: ./install.sh [caminho/do/picom.conf]
# Requer: picom >= 12, o tema Openbox windows-classic e aceleração 3D.
set -euo pipefail
cd "$(dirname "$0")"

CFGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/picom"
CONF="${1:-$CFGDIR/picom.conf}"
mkdir -p "$(dirname "$CONF")"
install -m644 windows-classic.glsl "$(dirname "$CONF")/windows-classic.glsl"
echo "Shader instalado em $(dirname "$CONF")/windows-classic.glsl"

if [ -f "$CONF" ]; then
    cp "$CONF" "$CONF.bak.$(date +%Y%m%d%H%M%S)"
else
    printf 'shadow = false;\nfading = false;\ncorner-radius = 0;\n' > "$CONF"
fi

python3 -I - "$CONF" <<'EOF_PY'
import re, sys

path = sys.argv[1]
text = open(path).read()

# Regras do Windows Classic (marcadas com "Windows Classic" para poderem ser
# trocadas numa reinstalação)
RULES = ["""{
  # Windows Classic: relevo 3D das janelas e menus do Openbox
  match = "_NET_FRAME_EXTENTS@[0] = 4 || "
          "(window_type = 'popup_menu' && !class_g)";
  shader = "windows-classic.glsl";
  corner-radius = 0;
}""", """{
  # Windows Classic: sombra dos menus ("Mostrar sombras sob os menus" do XP).
  # Menus com transparência (argb: Firefox, Chromium, Electron) desenham a
  # própria sombra numa margem transparente; a do picom ficaria descolada.
  match = "(window_type = 'popup_menu' || window_type = 'dropdown_menu') && !argb";
  shadow = true;
  full-shadow = false;
}"""]

# Sombra do XP: 5 px à direita e embaixo, de ~45% a 2% (medida num print
# do XP); nada em cima nem à esquerda
GLOBALS = {"shadow-radius": "4", "shadow-offset-x": "-2",
           "shadow-offset-y": "-2", "shadow-opacity": "0.5"}


def code_spans(s):
    """Posições de s que são código (fora de strings e comentários)."""
    i, n, out = 0, len(s), []
    while i < n:
        c = s[i]
        if c == '"':
            j = i + 1
            while j < n and s[j] != '"':
                j += 2 if s[j] == "\\" else 1
            i = j + 1
        elif c == "#" or s.startswith("//", i):
            i = s.find("\n", i)
            i = n if i < 0 else i
        elif s.startswith("/*", i):
            i = s.find("*/", i)
            i = n if i < 0 else i + 2
        else:
            out.append(i)
            i += 1
    return out


def find_rules(text):
    """(início do conteúdo, posição do ')' final) da lista rules, ou None."""
    code = code_spans(text)
    code_set = set(code)
    m = next((m for m in re.finditer(r"(?m)^[ \t]*rules[ \t]*[:=][ \t]*\(", text)
              if text.index("rules", m.start()) in code_set), None)
    if m is None:
        return None
    depth = 0
    for i in (p for p in code if p >= m.end() - 1):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return m.end(), i
    sys.exit("Não consegui encontrar o fim da lista 'rules' no picom.conf.")


def set_global(text, key, value):
    code_set = set(code_spans(text))
    m = next((m for m in re.finditer(rf"(?m)^[ \t]*{key}[ \t]*=[^;\n]*;?", text)
              if text.index(key, m.start()) in code_set), None)
    if m is None:
        return f"{key} = {value};\n" + text
    return text[:m.start()] + f"{key} = {value};" + text[m.end():]


# Opções antigas (*-exclude, wintypes...) não podem ser combinadas com "rules"
legacy = ("shadow-exclude", "fade-exclude", "opacity-rule", "focus-exclude",
          "rounded-corners-exclude", "blur-background-exclude", "wintypes",
          "window-shader-fg-rule", "corner-radius-rules")
used = [k for k in legacy if re.search(rf"(?m)^[ \t]*{k}\b", text)]
if used and find_rules(text) is None:
    sys.exit("O picom.conf usa opções antigas (" + ", ".join(used) + ") que não "
             "podem ser combinadas com 'rules'. Adicione manualmente as regras "
             "descritas em Extras/Picom/README.md.")

# backend: o shader só funciona com glx/egl
code_set = set(code_spans(text))
m = next((m for m in re.finditer(r"(?m)^[ \t]*backend[ \t]*=[ \t]*\"(\w+)\"[ \t]*;?", text)
          if text.index("backend", m.start()) in code_set), None)
if m is None:
    text = 'backend = "glx";\n' + text
elif m.group(1) not in ("glx", "egl"):
    text = text[:m.start()] + 'backend = "glx";' + text[m.end():]
    print(f'backend alterado de "{m.group(1)}" para "glx".')

# Parâmetros globais da sombra (só os menus têm sombra)
for key, value in GLOBALS.items():
    text = set_global(text, key, value)

# Remove regras do Windows Classic de uma instalação anterior
rules = find_rules(text)
if rules:
    start, close = rules
    code = [p for p in code_spans(text) if start <= p < close]
    items, depth, open_at = [], 0, None
    for i in code:
        if text[i] == "{":
            if depth == 0:
                open_at = i
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                items.append((open_at, i + 1))
    for a, b in reversed(items):
        body = text[a:b]
        if not ("windows-classic.glsl" in body
                or "Windows Classic: relevo" in body
                or "Windows Classic: sombra" in body):
            continue
        before = text[start:a].rstrip()
        if before.endswith(","):              # leva junto a vírgula anterior
            a = start + len(before) - 1
        else:                                 # ou a seguinte, se for o primeiro
            after = re.match(r"\s*,", text[b:close])
            if after:
                b += after.end()
        text = text[:a] + text[b:]
        close -= b - a
    # comentários soltos de uma instalação manual antiga
    region = re.sub(r"(?m)^[ \t]*#(-+ Windows Classic -+|[^\n]*windows-classic: borda|[^\n]*Relevo 3D da moldura)[^\n]*\n",
                    "", text[start:close])
    text = text[:start] + region + text[close:]

# Adiciona as regras ao fim da lista
rules = find_rules(text)
block = ",\n".join(RULES)
if rules is None:
    text = text.rstrip() + "\n\nrules: (" + block + ");\n"
else:
    start, close = rules
    inner = text[start:close].strip()
    sep = "," if re.search(r"\}\s*(#[^\n]*\s*)*$", inner) else ""
    text = text[:close].rstrip() + sep + "\n" + block + ")" + text[close + 1:]

open(path, "w").write(text)
print(f"Regras e sombra do Windows Classic aplicadas em {path}")
EOF_PY

if pgrep -x picom >/dev/null; then
    echo "Reinicie o picom para aplicar:  pkill -x picom; picom -b"
fi

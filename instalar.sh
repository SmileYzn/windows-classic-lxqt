#!/usr/bin/env bash
# Instala e ativa o tema Windows Classic completo nesta máquina.
#
#   1. instala todos os componentes no sistema (pede a senha do sudo)
#   2. ativa o tema no usuário atual (cada script faz backup do que altera)
#   3. reinicia o painel do LXQt
#
# Uso: ./instalar.sh [opções]      (rode como usuário comum, sem sudo)
#
#   --picom       também instala o extra do picom (relevo 3D e sombra dos
#                 menus) e reinicia o picom; requer picom e aceleração 3D
#   --sem-sddm    não instala nem ativa a tela de logon
#   --sem-painel  não muda o layout do painel (só tema, paleta e estilo)
#   --simular     só mostra os comandos, sem executar nada
#   -h, --help    mostra esta ajuda
set -euo pipefail
cd "$(dirname "$0")"

PICOM=0 SDDM=1 PAINEL=1 SIMULAR=0
for arg in "$@"; do
    case "$arg" in
        --picom)      PICOM=1 ;;
        --sem-sddm)   SDDM=0 ;;
        --sem-painel) PAINEL=0 ;;
        --simular)    SIMULAR=1 ;;
        -h|--help)    sed -n '2,/^set -/p' "$0" | grep '^#' | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Opção desconhecida: $arg (veja --help)" >&2; exit 1 ;;
    esac
done

if [ "$(id -u)" -eq 0 ]; then
    echo "Rode sem sudo: o script pede a senha quando precisar e também ativa o tema no seu usuário." >&2
    exit 1
fi

etapa() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
run() {
    printf '  $ %s\n' "$*"
    [ "$SIMULAR" -eq 1 ] || "$@"
}

# Dependências mínimas
faltando=()
for cmd in lxqt-panel openbox fc-match python3; do
    command -v "$cmd" >/dev/null || faltando+=("$cmd")
done
[ "$SDDM" -eq 1 ] && ! command -v sddm >/dev/null && faltando+=(sddm)
[ "$PICOM" -eq 1 ] && ! command -v picom >/dev/null && faltando+=(picom)
if [ "${#faltando[@]}" -gt 0 ]; then
    echo "Faltam programas: ${faltando[*]}" >&2
    echo "No Arch Linux: sudo pacman -S --needed lxqt openbox noto-fonts python sddm picom" >&2
    exit 1
fi

[ "$SIMULAR" -eq 1 ] || sudo -v    # pede a senha uma vez só

etapa "1/3 Instalando no sistema"
run sudo Wallpapers/install.sh
run sudo Fonts/install.sh
run sudo Openbox/install.sh
run sudo Cursors/install.sh
run sudo LXQT/install.sh
run sudo GTK/install.sh --default
if [ "$SDDM" -eq 1 ]; then
    run sudo SDDM/install.sh --enable
fi

etapa "2/3 Ativando no usuário $(id -un)"
run Openbox/install.sh --apply
run Cursors/install.sh --apply
run GTK/install.sh --apply
if [ "$PAINEL" -eq 1 ]; then
    run LXQT/apply.sh --panel
else
    run LXQT/apply.sh
fi
if [ "$PICOM" -eq 1 ]; then
    run Extras/Picom/install.sh
fi

etapa "3/3 Recarregando"
if pgrep -x lxqt-panel >/dev/null; then
    run pkill -x lxqt-panel          # a sessão do LXQt reabre o painel
fi
if [ "$PICOM" -eq 1 ] && pgrep -x picom >/dev/null; then
    run pkill -x picom
    [ "$SIMULAR" -eq 1 ] || sleep 1
    run picom -b
fi

etapa "Pronto"
cat <<EOF
  - Faça logout e login para o cursor e os apps GTK pegarem o tema.
  - Papel de parede: Preferências da área de trabalho → /usr/share/wallpapers/windows-classic
EOF
if [ "$SDDM" -eq 1 ]; then
    echo "  - A tela de logon muda no próximo boot (ou: sudo systemctl restart sddm — encerra a sessão)."
fi
if ! pacman -Q gtk4 libadwaita >/dev/null 2>&1; then
    echo "  - Apps GTK 4/libadwaita: instale gtk4 e libadwaita para usar essa parte do tema."
fi

## Windows Classic Theme para LXQT

# Sobre
Vou criar nessa pasta um tema completo para LXQT:
O tema deverá ser idêntico ao possível ao Tema clássico do windows XP.
Mas ao mesmo tempo é sábio que não é possível por regra ter exatamente o mesmo resultado.

Responder sempre em português do Brasil. Comentários de scripts e READMEs também em pt-BR.

# De onde tirar os recursos
Há uma pasta que você deve me perguntar onde está:
- Ela contém os arquivos da ISO de instalação do Windows XP (Professional SP3, pasta `I386`);
- Todos os recursos devem ser tirados de lá
- O caminho muda de máquina para máquina: pergunte antes de rodar qualquer `build.sh`.

Fontes de informação que já usamos na `I386`:
- `HIVEDEF.INF`: cores do esquema Clássico (`Control Panel\Colors`), medidas (`WindowMetrics`) e o esquema de sons (`AppEvents`);
- `LAYOUT.INF`: nomes longos dos arquivos (ex.: `XPDING.WA_` → "Windows XP Ding.wav");
- `SHL_IMG.IN_` e `ACCESSOR.IN_`: nomes dos papéis de parede;
- `EXPLORER.EX_`: bandeira do botão Iniciar (bitmap 176) e faixa "Windows XP Professional" (bitmap 167);
- `USER32.DL_` e `OLE32.DL_`: cursores; `USER32.DL_` também tem os ícones de mensagem (101 aviso, 103 erro, 104 informação);
- `BROWSEUI.DL_`: animação do Explorer (bitmap 306, 41 quadros de 22x22; idêntica à do Windows 2000);
- `MSGINA.DL_`: tela de logon (bitmaps 101/107 faixas, 103 barra; diálogos 1500 logon, 2200 desligar, 2507 falha).
Arquivos `*.XX_` são CAB: extrair com `cabextract`. Recursos de `.exe`/`.dll`: `7z x arquivo '.rsrc/...'`.

# Componentes
- O estilo do QT (Nas configurações do LXQT) já possui a variante Windows Clássico; o estilo Qt "Windows" já desenha botões e botões da barra de tarefas no padrão Clássico;
- Um tema de cursores;
- Um tema de janelas para o openbox;
- Um tema para o ambiente LXQT;
- Sem pacote de ícones próprio, por decisão do usuário (muito custoso para manter por agora): o tema usa qualquer tema de ícones instalado e nenhum componente depende de ícones;
- Os sons do Windows XP: o LXQT não tem suporte nativo, então a pasta Sounds guarda só os arquivos .wav (sem tema nem instalação);
- As fontes do tema: Noto Sans do próprio Linux. Não usamos as fontes da Microsoft (nem Tahoma, MS Sans Serif ou Marlett);
- Um tema GTK (`GTK/`), derivado do GTK 3 e do GTK 4 do win2k com as cores do XP Clássico. Sem GTK 2 (o `gtk2` saiu dos repositórios do Arch; decisão do usuário);
- O picom é um extra opcional (`Extras/Picom`): o tema do Openbox não pode depender dele.

# Caminhos
As pastas no projeto:

1. Wallpapers -> Tema de planos de fundo
2. Fonts -> Fontes do tema (Noto Sans)
3. Openbox -> Tema para openbox
4. Cursors -> Tema de cursores
5. Sounds -> Arquivos de som do Windows XP (só os .wav)
6. LXQT -> Tema do LXQT
7. SDDM -> Tema para o SDDM Login Manager

Fora da numeração: `GTK` (temas GTK 3 e GTK 4/libadwaita) e `Extras/Picom`.

Os passos do projeto serão do 1 ao 7.

## Estado atual
- Passos 1 a 6 prontos e publicados no GitHub, mais `Extras/Picom`.
- Passo 7 (SDDM) pronto: tema QML próprio (Qt 6, SDDM 0.21), sem QtQuick.Controls.
- GTK 3 e GTK 4 prontos (`GTK/windows-classic/gtk-3.0` e `gtk-4.0`).
- Cada pasta tem um `README.md` com a origem de cada recurso e as limitações. Leia o da pasta antes de mexer nela.

## Decisões já tomadas
- **Nome de todos os pacotes do tema: `windows-classic`, sem espaços.** Vale para pastas instaladas (`themes/`, `icons/`, `sddm/themes/`, `lxqt/themes/`, `lxqt/palettes/`, `wallpapers/`, `/usr/share/windows-classic`) e para o `Name=` dos `index.theme`/`metadata.desktop`. Arquivos de configuração e entradas de menu seguem em minúsculas (`60-windows-classic.conf`, `windows-classic.glsl`, `windows-classic-*.desktop`).
- Wallpapers, sons, cursores e imagens do menu Iniciar ficam no repositório (decisão do usuário), com o aviso de marcas da Microsoft no README principal.
- Openbox: título em Noto Sans Bold 9 + `padding.height: 1`, para a barra ter 18 px e os botões 14 px, como no XP. Glifos dos botões em pixel art no `Openbox/build.sh` (não usa a Marlett).
- Cursores: base do projeto win2k (os cursores do XP são idênticos aos do Windows 2000).
- LXQt: o menu do XP é o `mainmenu` (menu em cascata), com o arquivo `LXQT/menu/windows-classic-applications.menu`. O `fancymenu` só recebe o botão Iniciar igual.
- Botão Iniciar: 59x22 px, medido num print do XP.
- SDDM: reproduz o logon clássico (diálogo 1500 do msgina), não a tela de boas-vindas do Luna. "Fazer logon em:" (Opções >>) escolhe a sessão. Fundo `#3A6EA5`.
- GTK: mesmas cores da paleta Qt. ButtonDkShadow `#404040` (`@border_dark`), WindowFrame `#000000` (`@window_frame`, moldura do botão padrão e foco). A calha da barra de rolagem é xadrez branco/`#D4D0C8`. O tema fica em `themes/windows-classic`, junto do `openbox-3`: o `install.sh` de cada um só troca as próprias subpastas.
- Sombra dos menus (picom): `shadow-radius 4`, `offset -2,-2`, `opacity 0.5`, medida num print do XP. Só em menus opacos (`!argb`): Firefox/Chromium/Electron desenham a própria sombra numa margem transparente.
- GTK 4: barra de título CSD de 18 px com botões 16x14 e os glifos do Openbox (`titlebutton-*.png`). Apps libadwaita só pegam o tema pelo `@import` em `~/.config/gtk-4.0/gtk.css` (`GTK/install.sh --apply`).
- **Licenças: o usuário não vai definir nenhuma até o fim do projeto.** Não adicione arquivos `LICENSE` nem seções de licença nos READMEs; os créditos de origem (win2k, Chicago95) ficam.

# Como trabalhar
- **Instalação para testes é no sistema e quem roda é o usuário.** Ao terminar uma tarefa, mostre os comandos (`sudo .../install.sh` e, se houver, o passo de ativação no usuário). Não instale nada no sistema nem na conta do usuário por conta própria.
- Os instaladores só instalam: nada de comandos para remover arquivos ou temas antigos (decisão do usuário). As cópias sobrescrevem no lugar (`cp -r origem/. destino/`, `ln -sfn`), então reinstalar não cria pastas aninhadas.
- Todo `install.sh` deve aceitar `sudo` (caminhos do sistema), modo usuário e, quando fizer sentido, `DESTDIR=... ./install.sh --system` para testar numa raiz falsa.
- Scripts que alteram configuração do usuário fazem backup (`*.bak.AAAAMMDDhhmmss`) e mexem só nas chaves do tema.
- **Nunca capturar a tela real do usuário** (DISPLAY=:0). Testes visuais só em X isolado: `Xvfb :99` + `HOME`/`XDG_CONFIG_HOME`/`XDG_DATA_HOME` falsos no scratchpad + `dbus-run-session`, com `openbox`, `lxqt-panel`, `xterm`, `xdotool` e captura com `xwd -root | magick xwd:- saida.png`. Se precisar ver a sessão real (GPU, picom), peça ao usuário.
- Ao comparar com o XP, peça um print ao usuário e meça pixel a pixel (`magick ... txt:-`).
- Projeto de referência do usuário: https://github.com/smileyzn/win2k (tema Windows 2000 para XFCE). É a base preferida para copiar soluções.

## Armadilhas conhecidas
- **lxqt-panel 2.x**: toda seção de plugin no `panel.conf` precisa de `type=` (ex.: `type=mainmenu`); sem isso o plugin não carrega e não aparece erro. O padrão do sistema fica em `/etc/xdg/lxqt/panel.conf`.
- **lxqt-panel**: o `menu_file` do `mainmenu` precisa de caminho completo (o nome não é procurado em `~/.config/menus`).
- **lxqt-panel**: o menu do `mainmenu`/`fancymenu` herda a fonte do botão (negrito); o QSS força peso normal em `#TopLevelMainMenu` e `#TopLevelFancyMenu`.
- **lxqt-panel**: os invólucros dos plugins se chamam `#<themeId>Plugin` (ex.: `#VolumePlugin`); o plugin de discos é `LXQtMount`. Nomes de objeto confiáveis estão no código-fonte (`themeId()`, `setObjectName`); `strings` não acha os que são `QStringLiteral`.
- **QSS**: o `border-image` pinta o miolo da imagem por cima do `background`. As imagens de moldura (`frame.png`, `field.png`) têm miolo transparente por isso.
- **QSS**: botões do Qt somam margens internas; o botão Iniciar usa `padding` negativo para chegar aos 59 px.
- **lxqt-config-appearance** reescreve `~/.config/gtk-3.0/settings.ini`; configurações GTK do tema devem ir para os arquivos do sistema (`/etc/xdg/gtk-3.0/settings.ini`).
- **Openbox**: no LXQt atual o Openbox lê `~/.config/openbox/rc.xml` (não `lxqt-rc.xml`). Bordas são de uma cor só; o relevo 3D de 2 px só existe com o extra do picom.
- **picom**: o shader do extra reconhece a sombra dos botões pela cor `#817E7A`, gerada por `.bg.shadow: 101` no `themerc`. Não mude um sem o outro. Regras usam `_NET_FRAME_EXTENTS@` (o `@` lê a janela do aplicativo).
- **SDDM**: com um `qmldir` na pasta do tema, só os tipos listados nele ficam visíveis; todo componente novo precisa entrar no `qmldir`. Não dê a uma função QML o nome de uma função global do JS (ex.: `escape`): o tipo deixa de carregar. Teste com `sddm-greeter-qt6 --test-mode --theme <pasta>` no Xvfb; os erros aparecem em vermelho na tela do tema padrão (use uma tela alta para ler tudo).
- **SDDM**: os bitmaps do msgina têm 413 px, mas só 411 são válidos (274 DLU).
- **SDDM (X11)**: a tela de logon roda antes de qualquer configuração do usuário. A resolução do LXQt (`lxqt-config-monitor`) e o cursor do fundo são aplicados pelo `SDDM/windows-classic-xsetup` (`[X11] DisplayCommand`). O `xsetroot` do próprio SDDM tem limite de 1 s e falha no boot da VM. No Xvfb não dá para medir o cursor da janela raiz nem mudar a resolução com `xrandr`; o cursor sobre a janela do tema dá para medir com XFixes (`XFixesGetCursorImage`).
- **GTK 3 sem compositor**: a janela dos menus não recebe decoração CSD, então a moldura em `window decoration` não aparece. O `gtk-menu.css` desenha a moldura em `window.popup:not(.csd) > menu`.
- **GTK 3**: a classe `.default` sai do botão padrão quando outro botão tem o foco (como no Windows). Para testar a moldura, ponha o foco num campo de texto.
- **Captura no Xvfb**: o `xwd -root` mostra os menus GTK (janelas ARGB) pretos, até com o Adwaita. Para GTK, capture com `magick import -window root saida.png`.
- **GTK 4**: `button.image-button > image` tem padding de 4 px; regras para os botões da barra de título precisam de `.image-button` no seletor para vencer.
- **GTK 4 pelo `gtk.css` do usuário**: a folha do libadwaita também carrega (com `GTK_THEME` ela não carrega), e põe negrito nos botões. Teste os dois jeitos.
- **Testar GTK 4 sem instalar**: o usuário não tem `gtk4`/`libadwaita`. Baixe os pacotes (`pacman -Sp gtk4 libadwaita` + `curl`), extraia no scratchpad e use `LD_LIBRARY_PATH` e `GI_TYPELIB_PATH`.
- **Testes com Firefox no Xvfb**: nunca `pkill firefox` (mata o Firefox real do usuário); guarde o PID e use `kill $PID`.
- **picom em VM**: sem aceleração 3D, o backend `glx` deixa de redesenhar janelas. No Xvfb isso também acontece (llvmpipe); lá, use os testes só para a primeira pintura.

# GitHub

Repositório: https://github.com/smileyzn/windows-classic-lxqt (branch `main`).
Cada passo concluído entra como um novo commit. Commit e push só quando o usuário pedir.

# Referências
Há um tema com um resultado semelhante em:
https://github.com/pixelocdguy/windows-classic

Não devemos copiar a risca, mas usar alguns recursos do mesmo.
A intenção é criar um tema atualizado com o LXQT

# Ferramentas
Qualquer ferramenta que precisar para instalação no Arch Linux, me mostre como posso intalar.

Já usadas no projeto:

```bash
sudo pacman -S --needed cabextract 7zip icoutils imagemagick xorg-xcursorgen git github-cli \
    xorg-server-xvfb xorg-xwd xterm xdotool noto-fonts libcanberra picom sddm gtk3-demos
```

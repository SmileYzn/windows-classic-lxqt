# Extra: Picom — relevo 3D e sombras de menu do Windows Classic

**Opcional.** O tema Openbox `Windows-Classic` funciona sozinho, sem compositor. Este extra usa um shader do [picom](https://github.com/yshui/picom) para desenhar o que o Openbox não consegue: o relevo 3D de 2 px do Windows.

| | Só Openbox | Openbox + este extra |
|---|---|---|
| Moldura da janela (4 px) | cinza liso | claro em cima/à esquerda, escuro embaixo/à direita (`EDGE_RAISED`) |
| Botões do título | relevo de 1 px | relevo de 2 px (`#FFFFFF` / `#808080` / `#404040`), afundado ao clicar |
| Menu do Openbox | borda cinza de 1 px | borda 3D de 2 px |
| Menus (Iniciar, Qt, GTK, Openbox) | sem sombra | sombra do XP: 5 px à direita e embaixo |

## Requisitos

- picom 12 ou mais novo, com backend `glx` (OpenGL)
- **aceleração 3D**: no VirtualBox, ative *Configurações → Tela → Habilitar Aceleração 3D*. Sem ela, o picom com `glx` deixa de redesenhar partes das janelas (por exemplo, o título não fica cinza ao perder o foco).
- tema Openbox `Windows-Classic` ativo

## Instalação

```bash
sudo pacman -S --needed picom
./install.sh                     # usa ~/.config/picom/picom.conf
pkill -x picom; picom -b         # reinicia o picom
```

O script faz backup do `picom.conf`, troca o backend para `glx`, ajusta a sombra e adiciona estas regras ao fim de `rules`. Rodar de novo troca as regras antigas pelas novas:

```
{
  match = "_NET_FRAME_EXTENTS@[0] = 4 || "
          "(window_type = 'popup_menu' && !class_g)";
  shader = "windows-classic.glsl";
  corner-radius = 0;
},
{
  match = "(window_type = 'popup_menu' || window_type = 'dropdown_menu') && !argb";
  shadow = true;
  full-shadow = false;
}
```

E estes parâmetros globais, que só valem para os menus porque as janelas continuam com `shadow = false`:

```
shadow-radius = 4;
shadow-offset-x = -2;
shadow-offset-y = -2;
shadow-opacity = 0.5;
```

Com esses valores, a sombra fica igual à do XP com "Mostrar sombras sob os menus": 5 px à direita e embaixo, de ~45% a ~2% de escuro, e nada em cima ou à esquerda. Medi num print do XP: na borda direita de um submenu sobre o fundo `#3A6EA5`, o XP dá `#203D5C #274A6F #305B89 #37689C #396DA3`, e este ajuste dá `#203D5B #274A6F #305B89 #37689C #3A6DA4`.

- `_NET_FRAME_EXTENTS@[0] = 4`: janelas com a moldura de 4 px do tema. O `@` faz o picom ler a propriedade da janela do aplicativo, onde o Openbox a grava.
- `popup_menu && !class_g`: menus do próprio Openbox (os do Qt/GTK têm `WM_CLASS` e ficam de fora).
- `!argb`: menus com transparência ficam sem a sombra do picom. É o caso do Firefox, do Chromium e de apps Electron. Eles desenham os menus com cantos arredondados e a própria sombra, dentro de uma margem transparente de ~5 px em volta do menu. O picom calcula a sombra pela janela inteira, então ela ficava descolada do menu, com uma faixa do fundo no meio, além da sombra do próprio app. Os menus do LXQt, do Qt, do GTK 3 e do Openbox são opacos e continuam com a sombra do XP.

Se o seu `picom.conf` usa opções antigas (`shadow-exclude`, `wintypes` etc.), que não podem ser combinadas com `rules`, o script não altera nada. Nesse caso, adicione a regra acima à mão.

## Sugestões para ficar mais parecido com o XP

```
shadow = false;          # janelas sem sombra (o extra liga só nos menus)
fading = false;          # nem animações de abrir/fechar
corner-radius = 0;       # cantos retos
```

Nas regras de `tooltip`, use `opacity = 1`: as dicas do XP são opacas.

## Como funciona

O shader (`windows-classic.glsl`) redesenha as 2 linhas externas da moldura com as cores do esquema Clássico (`HIVEDEF.INF`). Ele identifica os botões pela cor da sombra que o Openbox gera com `.bg.shadow: 101` no `themerc` (`#817E7A`). Essa linha vira `#404040`, e a linha de face vizinha vira `#808080`. Por isso, se mudar `.bg.shadow` ou a cor dos botões no `themerc`, ajuste também a constante `MARKER` do shader.

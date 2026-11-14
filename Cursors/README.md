# Cursors — Windows Classic

Cursores padrão do Windows XP SP3 (esquema "Windows Padrão"), extraídos dos recursos de `user32.dll` e `ole32.dll` da pasta `I386`.

A estrutura e as ferramentas vêm do projeto [win2k](https://github.com/smileyzn/win2k) (`Cursor/Win2k_Cursors`). Os 22 cursores do XP são idênticos, pixel a pixel, aos do Windows 2000.

| Pasta | Conteúdo |
|---|---|
| `windows-classic/cursors/` | Tema Xcursor: 22 cursores (32 e 64 px) e 91 apelidos (nomes CSS, X11 e hashes do Qt/Mozilla) |
| `windows-classic/build/png/` | PNG de cada cursor (32 px original e 64 px ampliado sem suavização) |
| `windows-classic/build/*.in` | Configuração do `xcursorgen` (tamanho e ponto ativo) |
| `windows-classic/build/tools/` | `wincur.py` (decodifica cursores do Windows) e `build_cursors.py` |

## Origem de cada cursor

| Cursor | Recurso no XP |
|---|---|
| default, text, wait, crosshair, up-arrow, redimensionar (4), move, not-allowed, progress, help, pencil, pointer | `user32.dll`, grupos 100–114 |
| all-scroll | `user32.dll`, grupo 32654 |
| no-drop, dnd-move, copy, alias | `ole32.dll`, grupos 1–4 |
| vertical-text | `text` girado 90° |
| right_ptr | `default` espelhado |

Pixels de "inverter a tela" (como no I-beam do texto) viram preto com contorno branco, porque o Xcursor não tem esse modo.

## Instalação

```bash
./install.sh            # usuário atual (~/.local/share/icons)
sudo ./install.sh       # todo o sistema (/usr/share/icons)
./install.sh --apply    # instala e ativa no LXQt, tamanho 32
```

O `--apply` grava `cursor_theme=windows-classic` e `cursor_size=32` na seção `[Mouse]` de `~/.config/lxqt/session.conf`, e `Inherits=windows-classic` em `~/.icons/default/index.theme` (apps fora do LXQt). A mudança vale a partir do próximo login. Também dá para escolher em **Configurações do LXQt → Teclado e Mouse → Cursor**.

## Gerar de novo a partir da ISO

```bash
./build.sh /caminho/para/I386     # requer cabextract, 7zip, imagemagick, xorg-xcursorgen
```

Para só remontar os Xcursor a partir dos PNG: `windows-classic/build/make.sh`.

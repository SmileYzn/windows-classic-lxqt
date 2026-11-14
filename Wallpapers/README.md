# Wallpapers — Windows Classic

Planos de fundo originais do Windows XP SP3, extraídos da pasta `I386` da mídia de instalação.

| Pasta | Conteúdo | Origem no XP |
|---|---|---|
| `*.jpg` | 20 wallpapers (800x600), incluindo **Bliss** | `C:\WINDOWS\Web\Wallpaper` (`SHL_IMG.INF`) |
| `Tiles/*.png` | 11 texturas em mosaico (convertidas de BMP) | `C:\WINDOWS\*.bmp` (`ACCESSOR.INF`) |
| `windows-classic.png` | Cor sólida `#3A6EA5` | Cor padrão da área de trabalho no tema Clássico |

## Instalação

```bash
./install.sh        # usuário atual
sudo ./install.sh   # todo o sistema
```

## Uso no LXQt

Clique com o botão direito na área de trabalho → **Preferências da área de trabalho** → **Plano de fundo**:

- **Fotos (`*.jpg`)**: modo *Esticar* ou *Ajustar e cortar*.
- **Texturas (`Tiles/`)**: modo *Lado a lado* (igual ao "Lado a lado" do XP).
- **Visual Clássico autêntico**: modo *Cor sólida* com `#3A6EA5`, ou use `windows-classic.png`.

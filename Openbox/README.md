# Openbox — Windows Classic

Tema de janelas do Openbox que reproduz o tema **Windows Clássico** do Windows XP SP3.

## De onde vem cada recurso

| Recurso | Origem no XP |
|---|---|
| Cores (título, botões, menus) | `I386/HIVEDEF.INF` → `HKCU\Control Panel\Colors` |
| Medidas (moldura de 4 px, título de 18 px) | `I386/HIVEDEF.INF` → `WindowMetrics` |
| Glifos dos botões (✕ ▁ □ ❐) e seta de submenu | Pixel art em `build.sh`, com o tamanho e a posição dos botões do Classic |
| Fonte | **Noto Sans** do sistema (no XP era Tahoma) |

Os glifos já vêm gerados em `windows-classic/openbox-3/*.xbm`. Para gerá-los de novo:

```bash
./build.sh
```

## Instalação

```bash
# 1. Fonte Noto Sans
sudo pacman -S --needed noto-fonts

# 2. Instala e ativa o tema (cria backup de ~/.config/openbox/rc.xml)
./install.sh --apply
```

O `--apply` define no `rc.xml`:
- tema `windows-classic`;
- ordem dos botões `NLIMC` (ícone, título, minimizar, maximizar, fechar);
- fonte Noto Sans 8 nos menus e **Noto Sans Bold 9** no título. O Openbox calcula a altura da barra e dos botões a partir da fonte, e com 9 a barra fica com 18 px e os botões com 14 px de altura, como no XP.

Sem o `--apply`, o script só copia o tema. Depois é só escolhê-lo em **Configurações do LXQt → Aparência → Tema do Gerenciador de Janelas**, ou no `obconf-qt`.

## Limitações conhecidas

- O Openbox desenha bordas de **uma cor só** e relevos de 1 px. Por isso, a moldura do XP aparece como uma moldura cinza lisa de 4 px, e os botões têm relevo simples. Eles afundam ao clicar, com o glifo deslocado 1 px, como no Windows.
  → O extra opcional [`Extras/Picom`](../Extras/Picom) desenha o relevo 3D de 2 px por cima, via compositor. **O tema não depende dele.**
- Os botões são quadrados (14×14); no XP são 16×14.
- Entre o título e a janela fica uma faixa de 4 px (a largura da borda); no XP é 1 px.

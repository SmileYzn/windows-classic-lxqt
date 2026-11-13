# Fonts — Windows Classic

O tema usa a **Noto Sans**, que já vem nas distribuições Linux. As fontes da Microsoft (Tahoma, MS Sans Serif, Marlett) **não** são usadas nem distribuídas.

| Onde | Fonte | Equivalente no XP |
|---|---|---|
| Título das janelas (Openbox) | Noto Sans Bold 9 | Tahoma Bold 8 |
| Menus e OSD (Openbox) | Noto Sans 8 | Tahoma 8 |

No título usamos 9 em vez de 8 porque o Openbox calcula a altura da barra e dos botões a partir da fonte. Com Noto Sans Bold 9 e `padding.height: 1`, a barra fica com 18 px e os botões com 14 px de altura, como no XP.

## Substituição de fontes

`60-windows-classic.conf` (fontconfig) faz as fontes da interface do XP apontarem para a Noto Sans: **Tahoma**, **MS Sans Serif**, **Microsoft Sans Serif**, **MS Shell Dlg** e **MS Shell Dlg 2**. Assim, programas que pedem essas fontes, como apps do Wine, usam a mesma fonte do resto do tema.

## Instalação

```bash
sudo pacman -S --needed noto-fonts
./install.sh        # usuário atual
sudo ./install.sh   # todo o sistema
```

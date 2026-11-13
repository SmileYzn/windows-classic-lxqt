pragma Singleton
import QtQuick 2.15

// Cores do esquema "Padrão do Windows" (Clássico), de I386/HIVEDEF.INF
// (HKCU\Control Panel\Colors), e a fonte do tema.
QtObject {
    readonly property color buttonFace:     "#D4D0C8"   // 212 208 200
    readonly property color buttonLight:    "#D4D0C8"   // 212 208 200
    readonly property color buttonHilight:  "#FFFFFF"   // 255 255 255
    readonly property color buttonShadow:   "#808080"   // 128 128 128
    readonly property color buttonDkShadow: "#404040"   //  64  64  64
    readonly property color window:         "#FFFFFF"
    readonly property color windowText:     "#000000"
    readonly property color grayText:       "#808080"
    readonly property color hilight:        "#0A246A"   //  10  36 106
    readonly property color hilightText:    "#FFFFFF"
    readonly property color activeTitle:    "#0A246A"   //  10  36 106
    readonly property color gradientActiveTitle:   "#A6CAF0" // 166 202 240
    readonly property color titleText:      "#FFFFFF"
    readonly property color inactiveTitle:  "#808080"   // 128 128 128
    readonly property color gradientInactiveTitle: "#C0C0C0" // 192 192 192
    readonly property color inactiveTitleText:     "#D4D0C8" // 212 208 200
    readonly property color infoWindow:     "#FFFFE1"   // 255 255 225 (balões)
    readonly property color infoText:       "#000000"

    // No XP: Tahoma 8 (11 px). Aqui: Noto Sans 12 px, igual ao resto do tema (9 pt).
    readonly property string fontFamily: "Noto Sans"
    readonly property int fontPixelSize: 12

    // "&Senha:" -> "<u>S</u>enha:"   ("&&" vira "&")
    function mnemonic(s) {
        var out = "", i = 0
        while (i < s.length) {
            var c = s.charAt(i)
            if (c === "&" && i + 1 < s.length) {
                var n = s.charAt(i + 1)
                out += (n === "&") ? "&amp;" : "<u>" + htmlEscape(n) + "</u>"
                i += 2
            } else {
                out += htmlEscape(c)
                i++
            }
        }
        return out
    }
    function htmlEscape(c) {
        return c.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    }
    // Letra do atalho (Alt+letra) de um texto com "&", ou "" se não houver
    function mnemonicKey(s) {
        var m = /&([^&])/.exec(s)
        return m ? m[1].toUpperCase() : ""
    }
}

import QtQuick 2.15
import "."

// Balão de aviso (tooltip com TTS_BALLOON), como o "Caps Lock ativado" do XP:
// fundo amarelo-claro, borda preta, cantos arredondados e a ponta em cima,
// apontando para o campo. O ponto (tipX, 0) é a ponta.
Item {
    id: balloon
    property string title
    property string message
    property url icon
    signal dismissed
    readonly property int tipX: 16
    readonly property int stemHeight: 18
    readonly property int radius: 8

    width: 300
    height: stemHeight + body.height + 18

    Canvas {
        id: shape
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            var r = balloon.radius, t = balloon.stemHeight
            var w = width - 0.5, h = height - 0.5, l = 0.5
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.moveTo(l + r, t)
            ctx.lineTo(balloon.tipX + 0.5, t)
            ctx.lineTo(balloon.tipX + 0.5, 0.5)           // ponta
            ctx.lineTo(balloon.tipX + 20.5, t)
            ctx.lineTo(w - r, t)
            ctx.arcTo(w, t, w, t + r, r)
            ctx.lineTo(w, h - r)
            ctx.arcTo(w, h, w - r, h, r)
            ctx.lineTo(l + r, h)
            ctx.arcTo(l, h, l, h - r, r)
            ctx.lineTo(l, t + r)
            ctx.arcTo(l, t, l + r, t, r)
            ctx.closePath()
            ctx.fillStyle = Style.infoWindow
            ctx.fill()
            ctx.lineWidth = 1
            ctx.strokeStyle = "#000000"
            ctx.stroke()
        }
    }

    Column {
        id: body
        x: 10
        y: balloon.stemHeight + 9
        width: balloon.width - 20
        spacing: 8
        Row {
            spacing: 6
            Image {
                source: balloon.icon
                width: 16; height: 16
                smooth: false
            }
            Text {
                text: balloon.title
                anchors.verticalCenter: parent.verticalCenter
                color: Style.infoText
                font.family: Style.fontFamily
                font.pixelSize: Style.fontPixelSize
                font.bold: true
                renderType: Text.NativeRendering
            }
        }
        Text {
            width: parent.width
            text: balloon.message
            wrapMode: Text.WordWrap
            color: Style.infoText
            font.family: Style.fontFamily
            font.pixelSize: Style.fontPixelSize
            renderType: Text.NativeRendering
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: balloon.dismissed()
    }
}

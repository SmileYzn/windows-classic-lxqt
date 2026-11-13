import QtQuick 2.15
import "."

// Janela de diálogo do Clássico: moldura de 3 px (SM_CXDLGFRAME), barra de
// título de 18 px em degradê + 1 px de face (SM_CYCAPTION = 19). Sem botões
// na barra, como os diálogos do logon (sem WS_SYSMENU). Arrasta pelo título.
FocusScope {
    id: win
    property string title
    property bool active: true
    property int clientWidth: 413
    property int clientHeight: 200
    default property alias content: client.data

    width: clientWidth + 6
    height: clientHeight + 6 + 19

    Bevel {
        anchors.fill: parent
        outerTL: Style.buttonLight
        outerBR: Style.buttonDkShadow
        innerTL: Style.buttonHilight
        innerBR: Style.buttonShadow
        fill: Style.buttonFace
    }

    Rectangle {
        id: caption
        x: 3; y: 3
        width: parent.width - 6
        height: 18
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: win.active ? Style.activeTitle : Style.inactiveTitle }
            GradientStop { position: 1; color: win.active ? Style.gradientActiveTitle : Style.gradientInactiveTitle }
        }
        Text {
            x: 2
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 4
            elide: Text.ElideRight
            text: win.title
            color: win.active ? Style.titleText : Style.inactiveTitleText
            font.family: Style.fontFamily
            font.pixelSize: Style.fontPixelSize
            font.bold: true
            renderType: Text.NativeRendering
        }
        MouseArea {
            anchors.fill: parent
            drag.target: win
            drag.threshold: 0
        }
    }

    Item {
        id: client
        x: 3
        y: 3 + 19
        width: win.clientWidth
        height: win.clientHeight
    }
}

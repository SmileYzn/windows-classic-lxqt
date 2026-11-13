import QtQuick 2.15
import "."

// Campo de texto com moldura afundada (WS_EX_CLIENTEDGE), 20 px de altura
// (12 DLU). Senhas aparecem com "*", como no tema Clássico.
FocusScope {
    id: edit
    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias input: input
    signal accepted

    height: 20
    activeFocusOnTab: true

    Bevel {
        anchors.fill: parent
        outerTL: Style.buttonShadow
        outerBR: Style.buttonHilight
        innerTL: Style.buttonDkShadow
        innerBR: Style.buttonLight
        fill: edit.enabled ? Style.window : Style.buttonFace
    }

    TextInput {
        id: input
        focus: true
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        color: edit.enabled ? Style.windowText : Style.grayText
        selectionColor: Style.hilight
        selectedTextColor: Style.hilightText
        selectByMouse: true
        passwordCharacter: "*"
        font.family: Style.fontFamily
        font.pixelSize: Style.fontPixelSize
        renderType: Text.NativeRendering
        onAccepted: edit.accepted()
        onActiveFocusChanged: if (activeFocus) selectAll()
    }
}

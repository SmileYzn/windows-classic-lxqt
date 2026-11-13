import QtQuick 2.15
import QtQuick.Window 2.15
import "."

// Botão do Windows Clássico (DrawFrameControl), 75x23 px = 50x14 DLU.
// O botão padrão (Enter) ganha uma moldura preta; a moldura passa para o
// botão que estiver com o foco, como no Windows.
Item {
    id: btn
    property string text
    property bool isDefault: false
    readonly property bool isPushButton: true
    signal clicked

    width: 75
    height: 23
    activeFocusOnTab: enabled

    property bool keyDown: false
    readonly property bool down: (mouse.pressed && mouse.containsMouse) || keyDown

    // Mostra a moldura de padrão se tiver foco, ou se for o padrão e nenhum
    // outro botão estiver com o foco.
    readonly property bool showDefault: enabled && (activeFocus || (isDefault &&
        !(Window.activeFocusItem && Window.activeFocusItem.isPushButton === true)))

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        visible: btn.showDefault
    }

    // Normal
    Bevel {
        anchors.fill: parent
        anchors.margins: btn.showDefault ? 1 : 0
        visible: !btn.down
        outerTL: Style.buttonHilight
        outerBR: Style.buttonDkShadow
        innerTL: Style.buttonLight
        innerBR: Style.buttonShadow
        fill: Style.buttonFace
    }
    // Pressionado: moldura cinza de 1 px (com a moldura preta por fora)
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        visible: btn.down
        color: Style.buttonFace
        border.color: Style.buttonShadow
        border.width: 1
    }
    Rectangle {
        anchors.fill: parent
        visible: btn.down
        color: "transparent"
        border.color: "#000000"
        border.width: 1
    }

    // Texto desabilitado: em relevo (branco deslocado 1 px por baixo do cinza)
    Label {
        visible: !btn.enabled
        label: btn.text
        color: Style.buttonHilight
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1
        anchors.verticalCenterOffset: 1
    }
    Label {
        id: caption
        label: btn.text
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: btn.down ? 1 : 0
        anchors.verticalCenterOffset: btn.down ? 1 : 0
    }

    FocusRect {
        visible: btn.activeFocus
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: btn.down ? 5 : 4
        anchors.topMargin: btn.down ? 5 : 4
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: btn.enabled
        onPressed: btn.forceActiveFocus()
        onClicked: btn.clicked()
    }

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
            btn.keyDown = true
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            btn.clicked()
            event.accepted = true
        }
    }
    Keys.onReleased: function (event) {
        if (event.key === Qt.Key_Space && !event.isAutoRepeat && btn.keyDown) {
            btn.keyDown = false
            btn.clicked()
            event.accepted = true
        }
    }
    onActiveFocusChanged: if (!activeFocus) keyDown = false
}

import QtQuick 2.15
import QtQuick.Window 2.15
import "."

// Caixa de combinação só de lista (CBS_DROPDOWNLIST), 21 px de altura.
// model: lista de textos (array JS).
FocusScope {
    id: combo
    property var model: []
    property int currentIndex: 0
    readonly property string currentText:
        (currentIndex >= 0 && currentIndex < model.length) ? model[currentIndex] : ""
    property bool open: false
    property int hoverIndex: -1
    readonly property int itemHeight: 16

    height: 21
    activeFocusOnTab: true

    function choose(i) {
        if (i >= 0 && i < model.length)
            currentIndex = i
        open = false
    }

    Bevel {
        anchors.fill: parent
        outerTL: Style.buttonShadow
        outerBR: Style.buttonHilight
        innerTL: Style.buttonDkShadow
        innerBR: Style.buttonLight
        fill: combo.enabled ? Style.window : Style.buttonFace
    }

    // Item atual: com foco (e lista fechada) fica selecionado, com pontilhado.
    Rectangle {
        id: current
        x: 3; y: 3
        width: dropButton.x - 4
        height: parent.height - 6
        color: (combo.activeFocus && !combo.open) ? Style.hilight : "transparent"
        Text {
            anchors.fill: parent
            anchors.leftMargin: 2
            verticalAlignment: Text.AlignVCenter
            text: combo.currentText
            elide: Text.ElideRight
            color: (combo.activeFocus && !combo.open) ? Style.hilightText
                 : (combo.enabled ? Style.windowText : Style.grayText)
            font.family: Style.fontFamily
            font.pixelSize: Style.fontPixelSize
            renderType: Text.NativeRendering
        }
        FocusRect {
            anchors.fill: parent
            visible: combo.activeFocus && !combo.open
            color: "#FFFFFF"
        }
    }

    // Botão da seta: 16 px de largura (SM_CXVSCROLL)
    Item {
        id: dropButton
        x: parent.width - 2 - width
        y: 2
        width: 16
        height: parent.height - 4
        Bevel {
            anchors.fill: parent
            visible: !combo.open
            outerTL: Style.buttonLight
            outerBR: Style.buttonDkShadow
            innerTL: Style.buttonHilight
            innerBR: Style.buttonShadow
            fill: Style.buttonFace
        }
        Rectangle {
            anchors.fill: parent
            visible: combo.open
            color: Style.buttonFace
            border.color: Style.buttonShadow
        }
        DropArrow {
            x: Math.floor((parent.width - width) / 2) + (combo.open ? 1 : 0)
            y: Math.floor((parent.height - height) / 2) + (combo.open ? 1 : 0)
            color: combo.enabled ? "#000000" : Style.grayText
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: combo.enabled
        onPressed: {
            combo.forceActiveFocus()
            combo.hoverIndex = combo.currentIndex
            combo.open = !combo.open
        }
    }

    Keys.onPressed: function (event) {
        var alt = event.modifiers & Qt.AltModifier
        if (event.key === Qt.Key_F4 || (alt && (event.key === Qt.Key_Down || event.key === Qt.Key_Up))) {
            if (open) choose(hoverIndex)
            else { hoverIndex = currentIndex; open = true }
        } else if (open && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            choose(hoverIndex)
        } else if (open && event.key === Qt.Key_Escape) {
            open = false
        } else if (event.key === Qt.Key_Down) {
            if (open) hoverIndex = Math.min(hoverIndex + 1, model.length - 1)
            else currentIndex = Math.min(currentIndex + 1, model.length - 1)
        } else if (event.key === Qt.Key_Up) {
            if (open) hoverIndex = Math.max(hoverIndex - 1, 0)
            else currentIndex = Math.max(currentIndex - 1, 0)
        } else if (event.key === Qt.Key_Home) {
            if (open) hoverIndex = 0; else currentIndex = 0
        } else if (event.key === Qt.Key_End) {
            if (open) hoverIndex = model.length - 1; else currentIndex = model.length - 1
        } else {
            return
        }
        event.accepted = true
    }
    onActiveFocusChanged: if (!activeFocus) open = false

    // A lista aberta fica numa camada sobre a tela inteira: um clique fora fecha.
    Item {
        id: layer
        parent: combo.Window.contentItem ? combo.Window.contentItem : combo
        anchors.fill: parent
        visible: combo.open
        z: 1000

        MouseArea {
            anchors.fill: parent
            onPressed: combo.open = false
        }

        Rectangle {
            id: list
            readonly property point origin: combo.open ? combo.mapToItem(layer, 0, combo.height) : Qt.point(0, 0)
            x: origin.x
            y: origin.y
            width: combo.width
            height: combo.model.length * combo.itemHeight + 2
            color: Style.window
            border.color: "#000000"

            Repeater {
                model: combo.model
                Rectangle {
                    x: 1
                    y: 1 + index * combo.itemHeight
                    width: list.width - 2
                    height: combo.itemHeight
                    color: index === combo.hoverIndex ? Style.hilight : Style.window
                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        elide: Text.ElideRight
                        color: index === combo.hoverIndex ? Style.hilightText : Style.windowText
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontPixelSize
                        renderType: Text.NativeRendering
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: combo.hoverIndex = index
                        onClicked: combo.choose(index)
                    }
                }
            }
        }
    }
}

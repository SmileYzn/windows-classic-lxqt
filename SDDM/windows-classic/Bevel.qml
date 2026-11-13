import QtQuick 2.15

// Relevo 3D de 2 px do Windows Clássico: duas molduras de 1 px, cada uma com
// uma cor em cima/esquerda e outra embaixo/direita, e o miolo.
Item {
    property color outerTL
    property color outerBR
    property color innerTL
    property color innerBR
    property color fill: "transparent"

    Rectangle { x: 0; y: 0; width: parent.width - 1; height: 1; color: outerTL }
    Rectangle { x: 0; y: 0; width: 1; height: parent.height - 1; color: outerTL }
    Rectangle { x: 0; y: parent.height - 1; width: parent.width; height: 1; color: outerBR }
    Rectangle { x: parent.width - 1; y: 0; width: 1; height: parent.height; color: outerBR }

    Rectangle { x: 1; y: 1; width: parent.width - 3; height: 1; color: innerTL }
    Rectangle { x: 1; y: 1; width: 1; height: parent.height - 3; color: innerTL }
    Rectangle { x: 1; y: parent.height - 2; width: parent.width - 2; height: 1; color: innerBR }
    Rectangle { x: parent.width - 2; y: 1; width: 1; height: parent.height - 2; color: innerBR }

    Rectangle {
        x: 2; y: 2; width: parent.width - 4; height: parent.height - 4
        color: fill
    }
}

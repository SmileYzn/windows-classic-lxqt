import QtQuick 2.15

// Seta da caixa de combinação: triângulo de 7x4 px.
Item {
    property color color: "#000000"
    width: 7
    height: 4
    Repeater {
        model: 4
        Rectangle {
            x: index
            y: index
            width: 7 - 2 * index
            height: 1
            color: parent.color
        }
    }
}

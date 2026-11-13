import QtQuick 2.15
import "."

// Texto estático do diálogo, com "&" virando letra sublinhada.
Text {
    property string label
    text: Style.mnemonic(label)
    textFormat: Text.StyledText
    color: enabled ? Style.windowText : Style.grayText
    font.family: Style.fontFamily
    font.pixelSize: Style.fontPixelSize
    renderType: Text.NativeRendering
}

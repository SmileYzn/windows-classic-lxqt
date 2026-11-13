import QtQuick 2.15

// Retângulo pontilhado de foco (DrawFocusRect): pixels alternados.
Canvas {
    property color color: "#000000"
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.fillStyle = color
        var w = Math.floor(width), h = Math.floor(height), i
        for (i = 0; i < w; i += 2) {
            ctx.fillRect(i, 0, 1, 1)
            ctx.fillRect(i, h - 1, 1, 1)
        }
        for (i = 0; i < h; i += 2) {
            ctx.fillRect(0, i, 1, 1)
            ctx.fillRect(w - 1, i, 1, 1)
        }
    }
}

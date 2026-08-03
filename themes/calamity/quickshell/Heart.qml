import QtQuick

// A Terraria life heart, drawn as actual pixels.
//
// Nothing here is a glyph or an SVG: it is the 8x7 grid below blown up by an
// integer factor, which is the only way the edges stay square. Battery is
// shown as a row of these because that is how the game shows how alive you
// are.
Item {
    id: root

    property int pixel: 4
    property color fill: Theme.red
    property color shade: Qt.darker(fill, 1.5)
    property color outline: "#0b0d11"
    property real amount: 1.0     // 0..1, how full this heart is

    readonly property var grid: [
        ".OO..OO.",
        "OHHOOHHO",
        "OHHHHHHO",
        "OHHHHHHO",
        ".OHHHHO.",
        "..OHHO..",
        "...OO..."
    ]

    implicitWidth: 8 * pixel
    implicitHeight: 7 * pixel

    Repeater {
        model: 7 * 8
        Rectangle {
            readonly property int gx: index % 8
            readonly property int gy: Math.floor(index / 8)
            readonly property string cell: root.grid[gy][gx]
            // Emptying runs right-to-left, so a draining heart looks like it
            // is being eaten from the side rather than fading out.
            readonly property bool lit: (gx / 8) < root.amount

            x: gx * root.pixel
            y: gy * root.pixel
            width: root.pixel
            height: root.pixel
            visible: cell !== "."
            antialiasing: false
            color: cell === "O" ? root.outline
                                : (lit ? root.fill : root.shade)
        }
    }
}

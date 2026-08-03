import QtQuick

// An icon drawn as actual pixels, the same way Heart.qml is.
//
// Every icon in this shell is a grid of characters blown up by an integer
// factor. Nothing is a font glyph: a glyph gets hinted, antialiased and
// scaled by the font engine, which is exactly the smooth look this rice is
// trying not to have.
//
//   '.'  transparent      'O'  outline
//   'F'  biome accent     'W'  light
//   'G'  secondary        'D'  dim
Item {
    id: root

    property var grid: []
    property int pixel: 3
    property color outline: "#0b0d11"
    property color fill: Theme.ac
    property color light: Theme.fg
    property color second: Theme.ac2
    property color dim: Theme.dim

    readonly property int cols: grid.length > 0 ? grid[0].length : 0
    readonly property int rows: grid.length

    implicitWidth: cols * pixel
    implicitHeight: rows * pixel

    function colorFor(ch) {
        switch (ch) {
        case "O": return outline;
        case "F": return fill;
        case "W": return light;
        case "G": return second;
        case "D": return dim;
        }
        return "transparent";
    }

    Repeater {
        model: root.rows * root.cols
        Rectangle {
            readonly property int gx: index % root.cols
            readonly property int gy: Math.floor(index / root.cols)
            readonly property string cell: root.grid[gy][gx]

            x: gx * root.pixel
            y: gy * root.pixel
            width: root.pixel
            height: root.pixel
            visible: cell !== "."
            antialiasing: false
            color: root.colorFor(cell)
        }
    }
}

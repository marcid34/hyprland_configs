import QtQuick

// One Terraria inventory slot.
//
// The game draws a slot as a flat fill inside a hard double edge -- a dark
// outer line and a lighter inner one -- with no gradient, no rounding and no
// antialiasing. Everything in this shell is built out of these.
Rectangle {
    id: root

    property bool active: false
    property bool hovered: false
    property color accent: Theme.ac
    property alias label: text.text
    property int labelSize: 24
    property string labelFont: Theme.fontMain
    // A grid from Icons.qml. Set it and the slot draws that instead of text.
    property var icon: null
    property int iconPixel: 3

    signal clicked()

    implicitWidth: Theme.unit
    implicitHeight: Theme.unit

    color: active ? Qt.darker(accent, 2.4)
                  : (hovered ? Theme.bg3 : Theme.slot)
    border.width: Theme.edge
    border.color: active ? accent : Theme.slotEdge
    antialiasing: false

    // The inner highlight line. Terraria's slots read as raised because the
    // inner edge is lighter than the fill, not because of any shadow.
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.edge
        color: "transparent"
        border.width: 1
        border.color: root.active ? Qt.lighter(root.accent, 1.3)
                                  : Qt.lighter(Theme.slot, 1.6)
        antialiasing: false
    }

    Text {
        id: text
        visible: root.icon === null
        anchors.centerIn: parent
        color: root.active ? Qt.lighter(root.accent, 1.5) : Theme.fg1
        font.family: root.labelFont
        font.pixelSize: root.labelSize
        renderType: Text.NativeRendering
        antialiasing: false
    }

    // A slot carries either a label or a drawn icon, never both.
    PixelIcon {
        visible: root.icon !== null
        anchors.centerIn: parent
        grid: root.icon === null ? [] : root.icon
        pixel: root.iconPixel
        fill: root.active ? Qt.lighter(root.accent, 1.3) : root.accent
        light: Theme.fg
        second: Theme.ac2
        dim: Theme.dim
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.clicked()
    }
}

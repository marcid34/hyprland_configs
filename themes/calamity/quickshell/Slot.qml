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
        anchors.centerIn: parent
        color: root.active ? Qt.lighter(root.accent, 1.5) : Theme.fg1
        font.family: root.labelFont
        font.pixelSize: root.labelSize
        renderType: Text.NativeRendering
        antialiasing: false
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

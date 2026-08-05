import QtQuick

// Every panel, island and card in the shell is one of these.
//
// A fill, a hairline, and a one-pixel highlight along the top edge. The
// highlight is doing the real work: a flat rounded rectangle on a dark
// desktop reads as a hole, and the same rectangle with a lit top edge reads
// as a raised pane. It costs one Rectangle and no shader.
Rectangle {
    id: surface

    property bool hovered: false
    property bool interactive: false

    color: interactive && hovered ? Theme.bg2 : Theme.bg1
    radius: Theme.radius
    border.width: 1
    border.color: Theme.bg3
    antialiasing: true

    Behavior on color { ColorAnimation { duration: Theme.fast } }

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.leftMargin: parent.radius * 0.55
        anchors.rightMargin: parent.radius * 0.55
        anchors.topMargin: 1
        height: 1
        color: Theme.hi
    }
}

import QtQuick

// A compact control for the bar: icon, optional label, hover and active states.
// Used for every right-hand bar module so they share one hit target and one
// hover behaviour rather than each inventing its own.
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color tint: Theme.dim
    property bool active: false
    property bool hovered: false
    signal clicked()
    signal wheel(int delta)

    implicitWidth: row.implicitWidth + (label ? 22 : 18)
    implicitHeight: 28
    radius: height / 2
    color: active ? Qt.alpha(root.tint, 0.16)
                  : (hovered ? Theme.surface2 : "transparent")

    Behavior on color { ColorAnimation { duration: Theme.quick } }
    Behavior on implicitWidth { NumberAnimation { duration: Theme.quick; easing.type: Theme.easing } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.active ? root.tint : Theme.dim
            font.family: Theme.fontMono
            font.pixelSize: 14
            Behavior on color { ColorAnimation { duration: Theme.quick } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            text: root.label
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.clicked()
        onWheel: (w) => root.wheel(w.angleDelta.y)
    }
}

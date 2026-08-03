import QtQuick

// A real control, not a readout: drag or click anywhere on the track and the
// bound value follows. Used for volume, where it moves the actual PipeWire
// sink -- the point being that a Quickshell surface can drive the system, not
// just report on it.
Item {
    id: root

    property real value: 0          // 0..1
    property color tint: Theme.ac
    signal moved(real v)

    implicitHeight: 22

    function setFromX(x) {
        const v = Math.max(0, Math.min(1, x / width));
        root.moved(v);
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.line

        Rectangle {
            width: Math.max(height, parent.width * root.value)
            height: parent.height
            radius: parent.radius
            color: root.tint
            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation { duration: Theme.quick; easing.type: Theme.easing }
            }
        }
    }

    Rectangle {
        id: knob
        width: drag.pressed || drag.containsMouse ? 14 : 11
        height: width
        radius: width / 2
        color: Theme.fg
        border.width: 2
        border.color: root.tint
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.width - width, root.value * root.width - width / 2))
        Behavior on width { NumberAnimation { duration: Theme.quick } }
        Behavior on x {
            enabled: !drag.pressed
            NumberAnimation { duration: Theme.quick; easing.type: Theme.easing }
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: (m) => root.setFromX(m.x)
        onPositionChanged: (m) => { if (pressed) root.setFromX(m.x) }
    }
}

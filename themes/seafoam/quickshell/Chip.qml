import QtQuick

// The pressable unit of the whole shell — every clickable thing in the bar is
// one of these, so "what clicking feels like" is defined once, here.
//
// Three things happen on press, and all three matter:
//
//   scale     drops to 0.94 and springs back past 1 on release. This is the
//             entire illusion of physicality; without the overshoot on the
//             way back it feels like a dimmer switch.
//   fill      snaps in at `fast` and fades out at `base`. Asymmetric on
//             purpose: acknowledgement should be instant, withdrawal should
//             not draw the eye.
//   ring      a one-pixel accent border on the active state, so "this is on"
//             survives being looked at peripherally.
Item {
    id: chip

    property string icon: ""
    property string label: ""
    property color tint: Theme.dim
    property bool active: false
    property bool enabled: true
    property int radius: height / 2

    signal clicked()
    signal wheeled(int delta)

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 28
    opacity: enabled ? 1 : 0.4

    scale: ma.pressed ? 0.94 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Theme.base
            easing.type: Theme.pop
            easing.overshoot: 1.5
        }
    }

    Rectangle {
        id: fill
        anchors.fill: parent
        radius: chip.radius
        color: chip.active ? Theme.accentWash
             : ma.containsMouse ? Theme.bg2 : "transparent"
        border.width: chip.active ? 1 : 0
        border.color: Qt.rgba(chip.tint.r, chip.tint.g, chip.tint.b, 0.45)

        Behavior on color {
            ColorAnimation {
                duration: ma.containsMouse || chip.active ? Theme.fast : Theme.base
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: chip.label !== "" && chip.icon !== "" ? 7 : 0

        Text {
            visible: chip.icon !== ""
            text: chip.icon
            color: chip.active ? chip.tint : Theme.dim
            // Nerd Font, not the UI font: these are private-use-area glyphs
            // and Adwaita Sans has no coverage for them, so they resolve
            // through fontconfig fallback to whatever happens to answer —
            // which is how a mute icon ends up rendering as a shuffle arrow.
            font.family: Theme.fontMono
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Theme.fast } }
        }

        Text {
            visible: chip.label !== ""
            text: chip.label
            color: chip.active ? Theme.fg : Theme.fg1
            font.family: Theme.font
            font.pixelSize: 12
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Theme.fast } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: chip.enabled
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: chip.clicked()
        onWheel: (w) => chip.wheeled(w.angleDelta.y)
    }
}

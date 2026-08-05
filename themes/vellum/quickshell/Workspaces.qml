import QtQuick
import Quickshell.Hyprland

// Workspace indicator.
//
// One pill slides between slots rather than each slot recolouring in place.
// The difference is that a moving object tells you *which direction* you went,
// which a colour change cannot — you read it without looking at it.
//
// The pill is a sibling behind the dots, not a property of them, which is why
// it can travel across the gaps.
Item {
    id: ws

    property int count: 6
    readonly property int slot: 22
    readonly property int spacing: 4

    implicitWidth: count * slot + (count - 1) * spacing
    implicitHeight: 26

    readonly property int focused: Hyprland.focusedWorkspace
                                   ? Hyprland.focusedWorkspace.id : 1

    // The travelling pill. Clamped into range so a workspace outside 1..count
    // parks it at the end instead of throwing it off the island.
    Rectangle {
        readonly property int idx: Math.max(0, Math.min(ws.count - 1, ws.focused - 1))
        x: idx * (ws.slot + ws.spacing)
        width: ws.slot
        height: parent.height
        radius: height / 2
        color: Theme.accentWash
        border.width: 1
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)

        Behavior on x {
            NumberAnimation {
                duration: Theme.base
                easing.type: Theme.pop
                easing.overshoot: 1.1
            }
        }
    }

    Row {
        spacing: ws.spacing
        anchors.fill: parent

        Repeater {
            model: ws.count

            Item {
                required property int index
                readonly property int id: index + 1
                readonly property bool isFocused: ws.focused === id
                readonly property bool occupied:
                    Hyprland.workspaces.values.some(w => w.id === id)

                width: ws.slot
                height: ws.height

                // A dot when idle, a short bar when occupied, accent when
                // focused. Three states, one shape, no icon font involved.
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.isFocused ? 10 : (parent.occupied ? 8 : 5)
                    height: parent.isFocused ? 5 : (parent.occupied ? 5 : 5)
                    radius: height / 2
                    color: parent.isFocused ? Theme.accent
                         : parent.occupied ? Theme.dim : Theme.faint

                    Behavior on width {
                        NumberAnimation { duration: Theme.base; easing.type: Theme.enter }
                    }
                    Behavior on color { ColorAnimation { duration: Theme.base } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + parent.id)
                }
            }
        }
    }
}

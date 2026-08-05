import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

// The dashboard.
//
// Controls, not readouts. Everything on it either changes the system when you
// touch it or is a live number — nothing here is decoration that happens to
// update. It overlays rather than reserving space, and enters from the edge it
// is anchored to so the movement explains where it came from.
PanelWindow {
    id: root

    property bool open: false
    property real cpu: 0
    property real mem: 0
    property real volume: 0
    property bool muted: false
    property var player: null

    signal setVolume(real v)
    signal toggleMute()
    signal runCmd(string cmd)

    visible: open
    anchors { top: true; right: true; bottom: true }
    implicitWidth: 400
    color: "transparent"
    exclusiveZone: 0

    Surface {
        id: card
        width: 372
        anchors {
            top: parent.top
            right: parent.right
            topMargin: Theme.barHeight + Theme.gap * 2
            rightMargin: Theme.gap
        }
        height: Math.min(col.implicitHeight + Theme.pad * 2,
                         parent.height - Theme.barHeight - Theme.gap * 4)

        opacity: root.open ? 1 : 0
        transform: Translate { x: root.open ? 0 : 26 }
        Behavior on opacity {
            NumberAnimation { duration: Theme.base; easing.type: Theme.enter }
        }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: Theme.pad
            spacing: 14

            // ── meters ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Ring {
                    Layout.fillWidth: true
                    value: root.cpu
                    tint: Theme.accent
                    label: Math.round(root.cpu * 100) + "%"
                    caption: "cpu"
                }
                Ring {
                    Layout.fillWidth: true
                    value: root.mem
                    tint: Theme.accent2
                    label: Math.round(root.mem * 100) + "%"
                    caption: "mem"
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.bg3 }

            // ── audio ──
            Slider {
                Layout.fillWidth: true
                icon: root.muted ? "󰝟" : "󰕾"
                value: root.muted ? 0 : root.volume
                tint: root.muted ? Theme.faint : Theme.accent
                onMoved: (v) => root.setVolume(v)
            }

            // ── media ──
            Rectangle {
                Layout.fillWidth: true
                visible: root.player !== null
                implicitHeight: 62
                radius: Theme.radiusSm
                color: Theme.bg2
                border.width: 1
                border.color: Theme.bg3

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: root.player ? (root.player.trackTitle || "—") : ""
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.player ? (root.player.trackArtist || "") : ""
                            color: Theme.faint
                            font.family: Theme.font
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    Chip {
                        icon: "󰒮"
                        tint: Theme.dim
                        onClicked: if (root.player) root.player.previous()
                    }
                    Chip {
                        icon: root.player && root.player.isPlaying
                              ? "󰏤" : "󰐊"
                        tint: Theme.accent
                        active: true
                        onClicked: if (root.player) root.player.togglePlaying()
                    }
                    Chip {
                        icon: "󰒭"
                        tint: Theme.dim
                        onClicked: if (root.player) root.player.next()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.bg3 }

            // ── power ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Chip {
                    Layout.fillWidth: true
                    radius: Theme.radiusSm
                    implicitHeight: 34
                    icon: "󰌾"
                    label: "Lock"
                    tint: Theme.accent
                    onClicked: { root.runCmd("hyprlock"); root.open = false }
                }
                Chip {
                    Layout.fillWidth: true
                    radius: Theme.radiusSm
                    implicitHeight: 34
                    icon: "󰤄"
                    label: "Suspend"
                    tint: Theme.accent2
                    onClicked: { root.runCmd("systemctl suspend"); root.open = false }
                }
                Chip {
                    Layout.fillWidth: true
                    radius: Theme.radiusSm
                    implicitHeight: 34
                    icon: "󰐥"
                    label: "Power"
                    tint: Theme.red
                    onClicked: { root.runCmd("hyprctl dispatch exit"); root.open = false }
                }
            }
        }
    }

    // Click-away. Behind the card in stacking order, so it only catches the
    // strip of window the card does not cover.
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.open = false
    }
}

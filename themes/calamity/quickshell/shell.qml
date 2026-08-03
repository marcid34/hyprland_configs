//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// calamity — the Terraria shell.
//
// This rice does not use waybar. The whole surface is built out of one unit:
// the inventory slot in Slot.qml, a flat fill inside a hard double edge. Bar,
// side menu and every control are grids of those, so the desktop reads as the
// game's UI rather than as a bar that happens to be purple.
//
// Run by themes/shell.sh as:  quickshell --path <this file>
ShellRoot {
    id: root

    property bool menuOpen: false

    // ── shared helpers ───────────────────────────────────────────────────
    function run(cmd) {
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Battery, read straight from sysfs. UPower would work too, but this has
    // no service dependency and degrades to "no hearts" on a desktop.
    //
    // The battery is globbed rather than named: this machine calls it BAT1,
    // plenty call it BAT0, and hardcoding either is how you end up with a
    // shell that silently shows no hearts on someone else's laptop.
    property int battery: -1
    property bool charging: false

    Process {
        id: batteryProbe
        command: ["sh", "-c",
                  "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; " +
                  "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 1 && lines[0] !== "") {
                    root.battery = parseInt(lines[0]);
                    root.charging = lines.length > 1 && lines[1].trim() === "Charging";
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProbe.running = true
    }

    // ── the bar ──────────────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.unit + 10
            color: "transparent"

            // The slab. A hard accent line along the bottom instead of a
            // shadow, because a 2D game has no depth to cast one.
            Rectangle {
                anchors.fill: parent
                color: Theme.bg1
                antialiasing: false

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: Theme.edge
                    color: Theme.ac
                    antialiasing: false
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    anchors.bottomMargin: 5 + Theme.edge
                    spacing: 6

                    // menu toggle
                    Slot {
                        icon: root.menuOpen ? Icons.chevronLeft : Icons.chevronRight
                        iconPixel: 3
                        active: root.menuOpen
                        onClicked: root.menuOpen = !root.menuOpen
                    }

                    Item { Layout.preferredWidth: 4 }

                    // workspaces, as hotbar slots
                    Repeater {
                        model: 5
                        Slot {
                            required property int index
                            readonly property int ws: index + 1
                            label: String(ws)
                            labelFont: Theme.fontLabel
                            labelSize: 20
                            active: Hyprland.focusedWorkspace
                                    && Hyprland.focusedWorkspace.id === ws
                            onClicked: Hyprland.dispatch("workspace " + ws)
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // clock, wide slot
                    Slot {
                        implicitWidth: Theme.unit * 4
                        label: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
                        labelSize: 24
                        onClicked: root.run("~/.config/waybar/scripts/hud.sh")
                    }

                    Item { Layout.fillWidth: true }

                    // battery as life hearts
                    Rectangle {
                        visible: root.battery >= 0
                        implicitWidth: hearts.implicitWidth + 20
                        implicitHeight: Theme.unit
                        color: Theme.slot
                        border.width: Theme.edge
                        border.color: Theme.slotEdge
                        antialiasing: false

                        RowLayout {
                            id: hearts
                            anchors.centerIn: parent
                            spacing: 3
                            Repeater {
                                model: 5
                                Heart {
                                    required property int index
                                    pixel: 5
                                    // five hearts, 20% each
                                    amount: Math.max(0, Math.min(1,
                                        (root.battery - index * 20) / 20))
                                    fill: root.charging ? Theme.ac2
                                        : (root.battery <= 20 ? Theme.red : "#d8455f")
                                }
                            }
                        }
                    }

                    // the biome switch
                    Slot {
                        implicitWidth: Theme.unit * 3
                        label: Theme.label
                        labelFont: Theme.fontLabel
                        labelSize: 18
                        active: true
                        accent: Theme.ac
                        onClicked: root.run("setsid -f ~/.config/themes/calamity/mode.sh --toggle")
                    }

                    Slot {
                        icon: Icons.power
                        iconPixel: 3
                        accent: Theme.red
                        onClicked: root.run("~/.config/waybar/scripts/power.sh")
                    }
                }
            }
        }
    }

    // ── the side menu ────────────────────────────────────────────────────
    // A Terraria inventory: a grid of slots, opened from the bar. Kept as a
    // separate layer-shell window so it overlays without resizing anything.
    PanelWindow {
        id: menu
        visible: root.menuOpen

        anchors { top: true; left: true; bottom: true }
        implicitWidth: Theme.unit * 5 + 40
        color: "transparent"
        // Overlay rather than reserve space: the desktop should not reflow
        // every time this opens.
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: Theme.unit + 10
            color: Theme.bg1
            border.width: Theme.edge
            border.color: Theme.ac
            antialiasing: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    text: "INVENTORY"
                    color: Theme.ac
                    font.family: Theme.fontLabel
                    font.pixelSize: 18
                    renderType: Text.NativeRendering
                    Layout.alignment: Qt.AlignHCenter
                }

                GridLayout {
                    columns: 4
                    columnSpacing: 6
                    rowSpacing: 6
                    Layout.alignment: Qt.AlignHCenter

                    Repeater {
                        model: [
                            { art: Icons.launcher, tip: "launcher", cmd: "~/.config/themes/launch.sh" },
                            { art: Icons.terminal, tip: "terminal", cmd: "alacritty" },
                            { art: Icons.files,    tip: "files",    cmd: "thunar" },
                            { art: Icons.biome,    tip: "biome",    cmd: "setsid -f ~/.config/themes/calamity/mode.sh --toggle" },
                            { art: Icons.rices,    tip: "rices",    cmd: "~/.config/themes/picker.sh" },
                            { art: Icons.lock,     tip: "lock",     cmd: "hyprlock" },
                            { art: Icons.shot,     tip: "shot",     cmd: "grim -g \"$(slurp)\" - | swappy -f -" },
                            { art: Icons.power,    tip: "power",    cmd: "~/.config/waybar/scripts/power.sh" }
                        ]
                        Slot {
                            required property var modelData
                            icon: modelData.art
                            iconPixel: 3
                            onClicked: {
                                root.run(modelData.cmd);
                                root.menuOpen = false;
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.bg3
                }

                // biome readout
                ColumnLayout {
                    spacing: 3
                    Text {
                        text: "BIOME"
                        color: Theme.dim
                        font.family: Theme.fontLabel
                        font.pixelSize: 13
                        renderType: Text.NativeRendering
                    }
                    Text {
                        text: Theme.label
                        color: Theme.ac
                        font.family: Theme.fontMain
                        font.pixelSize: 26
                        renderType: Text.NativeRendering
                    }
                    Text {
                        text: "click the biome slot to\nswitch to " + Theme.other
                        color: Theme.dim
                        font.family: Theme.fontMain
                        font.pixelSize: 15
                        lineHeight: 1.1
                        renderType: Text.NativeRendering
                    }
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "calamity"
                    color: Theme.bg4
                    font.family: Theme.fontLabel
                    font.pixelSize: 13
                    renderType: Text.NativeRendering
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}

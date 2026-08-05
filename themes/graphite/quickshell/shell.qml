//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray

// graphite — desktop shell.
//
// Neutral to the point of silence, with one warm signal in it.
//
// Three floating islands rather than one bar across the top. A single full
// width bar has to be a background — it touches both screen edges, so it
// belongs to the screen. Islands sit *on* the wallpaper, which is what lets
// the desktop stay visible as a surface rather than becoming a frame.
//
// Left  : workspaces, focused window
// Centre: clock (click for the dashboard)
// Right : media, tray, volume, battery, launcher
//
// Everything animated goes through Theme's three durations and three curves.
// The components in this directory hold all of the interaction feel; this file
// only decides what appears where.
ShellRoot {
    id: root

    property bool dashOpen: false
    property alias launcherOpen: launcher.open

    function run(cmd) { Quickshell.execDetached(["sh", "-c", cmd]) }

    SystemClock { id: clock; precision: SystemClock.Seconds }

    // ── sampling ─────────────────────────────────────────────────────────
    // /proc, read and differenced in QML. No helper process and no polling
    // script: CPU is the standard idle-vs-total delta between two reads, which
    // is why it needs the previous sample kept around.
    property real cpu: 0
    property real mem: 0
    property var _prev: null

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + (f[4] || 0);
            const total = f.reduce((a, b) => a + b, 0);
            if (root._prev) {
                const dt = total - root._prev.total;
                const di = idle - root._prev.idle;
                if (dt > 0) root.cpu = Math.max(0, Math.min(1, 1 - di / dt));
            }
            root._prev = { idle: idle, total: total };
        }
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: {
            const m = {};
            for (const line of text().split("\n")) {
                const p = line.split(":");
                if (p.length === 2) m[p[0]] = parseInt(p[1]) * 1024;
            }
            const totalKb = m["MemTotal"] || 1;
            root.mem = (totalKb - (m["MemAvailable"] || 0)) / totalKb;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { statFile.reload(); memFile.reload() }
    }

    // ── audio ────────────────────────────────────────────────────────────
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    function setVolume(v) {
        if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, v));
    }
    function toggleMute() {
        if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
    }

    // ── media / battery ──────────────────────────────────────────────────
    readonly property var player: Mpris.players.values.length > 0
                                  ? Mpris.players.values[0] : null

    readonly property var batt: UPower.displayDevice
    readonly property real battPct: batt && batt.isLaptopBattery
        ? (batt.percentage > 1 ? batt.percentage / 100 : batt.percentage) : -1
    readonly property bool charging: batt
        ? batt.state === UPowerDeviceState.Charging : false

    function battIcon() {
        if (charging) return "󰂄";
        const p = battPct;
        if (p < 0) return "󰚥";
        if (p > 0.9)  return "󰂂";
        if (p > 0.7)  return "󰂀";
        if (p > 0.45) return "󰁾";
        if (p > 0.2)  return "󰁼";
        return "󰁺";
    }

    // ── the bar ──────────────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight + Theme.gap * 2
            color: "transparent"

            // The islands drop in together on shell start. `ready` flips one
            // frame later so the transition has a state to animate *from* —
            // binding straight to true would have them simply exist.
            //
            // Referenced as `panel.ready` rather than through a parent chain:
            // a Translate is not a visual item and has no `parent`, so
            // `parent.parent.ready` inside one resolves to undefined at
            // runtime rather than failing at load.
            property bool ready: false
            Component.onCompleted: readyTimer.start()
            Timer {
                id: readyTimer
                interval: 60
                onTriggered: panel.ready = true
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.gap
                spacing: Theme.gap

                // ── left island ──
                Surface {
                    Layout.preferredHeight: Theme.barHeight
                    Layout.preferredWidth: leftRow.implicitWidth + 22

                    opacity: panel.ready ? 1 : 0
                    transform: Translate { y: panel.ready ? 0 : -14 }
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.slow; easing.type: Theme.enter }
                    }

                    RowLayout {
                        id: leftRow
                        anchors.fill: parent
                        anchors.leftMargin: 11
                        anchors.rightMargin: 11
                        spacing: 11

                        Workspaces {}

                        Rectangle {
                            width: 1
                            Layout.preferredHeight: 15
                            color: Theme.bg3
                        }

                        Text {
                            id: titleText
                            Layout.maximumWidth: 300
                            elide: Text.ElideRight
                            text: Hyprland.activeToplevel
                                  ? Hyprland.activeToplevel.title : "Desktop"
                            color: Theme.dim
                            font.family: Theme.font
                            font.pixelSize: 12

                            // Title changes cross-fade instead of snapping.
                            // 110ms each way is under the threshold where it
                            // would feel like waiting, and it stops the bar
                            // flickering as you move between windows.
                            //
                            // PropertyAction with no target is what actually
                            // assigns the new text, at the midpoint while the
                            // label is invisible. The two NumberAnimations must
                            // name `titleText` explicitly — a Behavior is not a
                            // visual item, so `parent` inside one is the
                            // enclosing layout, and targeting that would fade
                            // the whole island instead of the label.
                            Behavior on text {
                                SequentialAnimation {
                                    NumberAnimation {
                                        target: titleText; property: "opacity"
                                        to: 0; duration: Theme.fast
                                    }
                                    PropertyAction {}
                                    NumberAnimation {
                                        target: titleText; property: "opacity"
                                        to: 1; duration: Theme.fast
                                    }
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // ── centre island ──
                Surface {
                    id: centre
                    Layout.preferredHeight: Theme.barHeight
                    Layout.preferredWidth: centreRow.implicitWidth + 26
                    interactive: true
                    hovered: centreMa.containsMouse

                    opacity: panel.ready ? 1 : 0
                    transform: Translate { y: panel.ready ? 0 : -14 }
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.slow; easing.type: Theme.enter }
                    }

                    scale: centreMa.pressed ? 0.97 : 1
                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.base
                            easing.type: Theme.pop
                            easing.overshoot: 1.4
                        }
                    }

                    RowLayout {
                        id: centreRow
                        anchors.centerIn: parent
                        spacing: 9

                        Text {
                            text: Qt.formatDateTime(clock.date, "HH:mm")
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                        Rectangle { width: 3; height: 3; radius: 1.5; color: Theme.faint }
                        Text {
                            text: Qt.formatDateTime(clock.date, "ddd d MMM")
                            color: Theme.dim
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: centreMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.dashOpen = !root.dashOpen
                    }
                }

                Item { Layout.fillWidth: true }

                // ── right island ──
                Surface {
                    Layout.preferredHeight: Theme.barHeight
                    Layout.preferredWidth: rightRow.implicitWidth + 20

                    opacity: panel.ready ? 1 : 0
                    transform: Translate { y: panel.ready ? 0 : -14 }
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.slow; easing.type: Theme.enter }
                    }

                    RowLayout {
                        id: rightRow
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 3

                        Chip {
                            visible: root.player !== null
                            icon: root.player && root.player.isPlaying
                                  ? "󰏤" : "󰐊"
                            label: root.player
                                   ? (root.player.trackTitle || "").slice(0, 22) : ""
                            tint: Theme.accent2
                            active: root.player !== null && root.player.isPlaying
                            onClicked: if (root.player) root.player.togglePlaying()
                        }

                        // Tray. Icons scale up slightly on hover — the only
                        // affordance available when the icon itself is drawn
                        // by another application.
                        Row {
                            spacing: 1
                            Layout.alignment: Qt.AlignVCenter

                            Repeater {
                                model: SystemTray.items

                                Item {
                                    required property var modelData
                                    width: 24; height: 24

                                    Image {
                                        id: trayIcon
                                        anchors.centerIn: parent
                                        width: 15; height: 15
                                        source: modelData.icon
                                        smooth: true
                                        asynchronous: true
                                        scale: trayMa.containsMouse ? 1.18 : 1
                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.base
                                                easing.type: Theme.pop
                                                easing.overshoot: 1.6
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: trayMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.activate()
                                    }
                                }
                            }
                        }

                        Chip {
                            icon: root.muted ? "󰝟"
                                : (root.volume > 0.5 ? "󰕾" : "󰖀")
                            label: root.muted ? "muted"
                                              : Math.round(root.volume * 100) + "%"
                            tint: Theme.accent
                            active: root.muted
                            onClicked: root.toggleMute()
                            onWheeled: (d) => root.setVolume(root.volume + (d > 0 ? 0.03 : -0.03))
                        }

                        Chip {
                            visible: root.battPct >= 0
                            icon: root.battIcon()
                            label: Math.round(root.battPct * 100) + "%"
                            tint: root.charging ? Theme.green
                                : (root.battPct < 0.2 ? Theme.red : Theme.dim)
                            active: root.battPct < 0.2 && !root.charging
                        }

                        Chip {
                            icon: "󰍉"
                            tint: Theme.accent
                            active: root.launcherOpen
                            onClicked: root.launcherOpen = !root.launcherOpen
                        }
                    }
                }
            }
        }
    }

    // ── surfaces ─────────────────────────────────────────────────────────
    Launcher { id: launcher }

    Dash {
        id: dash
        open: root.dashOpen
        cpu: root.cpu
        mem: root.mem
        volume: root.volume
        muted: root.muted
        player: root.player
        onSetVolume: (v) => root.setVolume(v)
        onToggleMute: root.toggleMute()
        onRunCmd: (c) => root.run(c)
        onOpenChanged: root.dashOpen = open
    }

    // ── IPC ──────────────────────────────────────────────────────────────
    // Reached from keybinds through themes/qsipc.sh, which the repo already
    // binds to SUPER+SPACE and SUPER+D. Using IPC rather than Quickshell's
    // GlobalShortcut keeps the keys defined in one place — the compositor
    // config — instead of split across two.
    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.open = !launcher.open }
        function reveal(): void { launcher.open = true }
        function hide():   void { launcher.open = false }
    }

    IpcHandler {
        target: "palette"   // alias: SUPER+SPACE is bound to `palette toggle`
        function toggle(): void { launcher.open = !launcher.open }
        function reveal(): void { launcher.open = true }
        function hide():   void { launcher.open = false }
    }

    IpcHandler {
        target: "dash"
        function toggle(): void { root.dashOpen = !root.dashOpen }
        function reveal(): void { root.dashOpen = true }
        function hide():   void { root.dashOpen = false }
    }
}

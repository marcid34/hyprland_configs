//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray

// QShell Showcase — one QML codebase, three surfaces, everything live.
//
// A floating bar, a dashboard that drives the system rather than reporting on
// it, and the sampling behind both. Written to be read: the components in this
// directory are small and generic, and this file is the only place that knows
// what the desktop actually looks like.
ShellRoot {
    id: root

    property bool dashOpen: false
    // Variants delegates cannot see sibling ids, but they can see `root`.
    // Aliasing the palette's state here is what lets the bar button drive it.
    property alias paletteOpen: palette.open

    function run(cmd) { Quickshell.execDetached(["sh", "-c", cmd]) }

    SystemClock { id: clock; precision: SystemClock.Seconds }

    // ── sampling ─────────────────────────────────────────────────────────
    // /proc read directly and differenced in QML. No helper process, no
    // polling shell script -- the numbers on the dashboard come from four
    // lines of arithmetic below.
    property real cpu: 0
    property real memUsed: 0
    property real memTotal: 1
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
            root.memTotal = m["MemTotal"] || 1;
            root.memUsed = root.memTotal - (m["MemAvailable"] || 0);
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            cpuGraph.push(root.cpu * 100);
            memGraph.push(root.memUsed / root.memTotal * 100);
        }
    }

    // Bind the default sink so its volume is readable and writable.
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    function setVolume(v) {
        if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, v));
    }

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
        if (p > 0.9) return "󰂂";
        if (p > 0.7) return "󰂀";
        if (p > 0.45) return "󰁾";
        if (p > 0.2) return "󰁼";
        return "󰁺";
    }

    // ── the bar ──────────────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight + Theme.gap * 2
            color: "transparent"

            Card {
                anchors.fill: parent
                anchors.margins: Theme.gap
                anchors.topMargin: Theme.gap

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    // ── workspaces ──
                    // The active one widens rather than changing colour alone,
                    // so the eye tracks the movement instead of hunting a dot.
                    Row {
                        spacing: 5
                        Repeater {
                            model: 6
                            Rectangle {
                                required property int index
                                readonly property int ws: index + 1
                                readonly property bool active:
                                    Hyprland.focusedWorkspace
                                    && Hyprland.focusedWorkspace.id === ws
                                readonly property bool used:
                                    Hyprland.workspaces.values.some(w => w.id === ws)

                                width: active ? 26 : 8
                                height: 8
                                radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: active ? Theme.ac
                                              : (used ? Theme.faint : Theme.line)

                                Behavior on width {
                                    NumberAnimation { duration: Theme.slow; easing.type: Theme.easing }
                                }
                                Behavior on color { ColorAnimation { duration: Theme.quick } }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -5
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch("workspace " + parent.ws)
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.leftMargin: 4
                        width: 1; height: 16
                        color: Theme.line
                    }

                    Text {
                        Layout.maximumWidth: 320
                        elide: Text.ElideRight
                        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
                        color: Theme.dim
                        font.family: Theme.font
                        font.pixelSize: 12
                    }

                    Item { Layout.fillWidth: true }

                    // ── now playing ──
                    Pill {
                        visible: root.player !== null
                        icon: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                        label: root.player
                               ? (root.player.trackTitle || "").slice(0, 28) : ""
                        tint: Theme.ac2
                        onClicked: if (root.player) root.player.togglePlaying()
                    }

                    Item { Layout.fillWidth: true }

                    // ── tray ──
                    Row {
                        spacing: 2
                        Repeater {
                            model: SystemTray.items
                            Item {
                                required property var modelData
                                width: 24; height: 24
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    anchors.centerIn: parent
                                    width: 15; height: 15
                                    source: modelData.icon
                                    smooth: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }

                    // ── volume ──
                    Pill {
                        icon: root.muted ? "󰝟" : (root.volume > 0.5 ? "󰕾" : "󰖀")
                        label: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
                        tint: Theme.ac
                        onClicked: if (root.sink && root.sink.audio)
                                       root.sink.audio.muted = !root.sink.audio.muted
                        onWheel: (d) => root.setVolume(root.volume + (d > 0 ? 0.03 : -0.03))
                    }

                    // ── battery ──
                    Pill {
                        visible: root.battPct >= 0
                        icon: root.battIcon()
                        label: Math.round(root.battPct * 100) + "%"
                        tint: root.charging ? Theme.ac2
                              : (root.battPct < 0.2 ? Theme.red : Theme.dim)
                    }

                    Text {
                        text: Qt.formatDateTime(clock.date, "ddd d MMM")
                        color: Theme.faint
                        font.family: Theme.font
                        font.pixelSize: 12
                    }

                    Text {
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Pill {
                        icon: "󰍉"
                        tint: Theme.ac
                        active: root.paletteOpen
                        onClicked: root.paletteOpen = !root.paletteOpen
                    }

                    Pill {
                        icon: "󰕮"
                        tint: Theme.ac
                        active: root.dashOpen
                        onClicked: root.dashOpen = !root.dashOpen
                    }
                }
            }
        }
    }

    // The shell registers its own hotkey rather than asking you to edit the
    // compositor config. Super+Space opens the palette.
    GlobalShortcut {
        appid: "qshell"
        name: "palette"
        description: "Open the QShell command palette"
        onPressed: palette.open = !palette.open
    }

    CommandPalette { id: palette }

    // The shell exposes an API. `qs ipc call palette toggle` from any script,
    // keybind or CI job drives the running shell -- no restart, no config
    // reload, no separate daemon. This is also how the surfaces get tested.
    IpcHandler {
        target: "palette"
        function toggle(): void { palette.open = !palette.open }
        function reveal(): void { palette.open = true }
        function hide(): void { palette.open = false }
    }

    IpcHandler {
        target: "dash"
        function toggle(): void { root.dashOpen = !root.dashOpen }
        function reveal(): void { root.dashOpen = true }
        function hide(): void { root.dashOpen = false }
    }

    // ── the dashboard ────────────────────────────────────────────────────
    // Overlays rather than reserving space, and animates in from the edge it
    // is anchored to. Everything in it is either live or interactive.
    PanelWindow {
        id: dash
        visible: root.dashOpen

        anchors { top: true; right: true; bottom: true }
        implicitWidth: 440
        color: "transparent"
        exclusiveZone: 0

        Card {
            id: dashCard
            width: 420
            anchors {
                top: parent.top
                right: parent.right
                topMargin: Theme.barHeight + Theme.gap * 2
                rightMargin: Theme.gap
            }
            height: Math.min(dashCol.implicitHeight + Theme.pad * 2,
                             parent.height - Theme.barHeight - Theme.gap * 4)

            // Slide + fade in. The bar toggle flips `dashOpen`; this is the
            // only place the transition is described.
            opacity: root.dashOpen ? 1 : 0
            transform: Translate { x: root.dashOpen ? 0 : 24 }
            Behavior on opacity { NumberAnimation { duration: Theme.slow; easing.type: Theme.easing } }

            ColumnLayout {
                id: dashCol
                anchors.fill: parent
                anchors.margins: Theme.pad
                spacing: 16

                // ── greeting ──
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: {
                            const h = clock.date.getHours();
                            return h < 5 ? "Still up" : h < 12 ? "Good morning"
                                 : h < 18 ? "Good afternoon" : "Good evening";
                        }
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 19
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
                        color: Theme.faint
                        font.family: Theme.font
                        font.pixelSize: 12
                    }
                }

                // ── media ──
                Card {
                    visible: root.player !== null
                    Layout.fillWidth: true
                    implicitHeight: 84
                    color: Theme.surface2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 11
                        spacing: 12

                        Rectangle {
                            width: 60; height: 60
                            radius: Theme.radiusSm
                            color: Theme.line
                            clip: true
                            Image {
                                anchors.fill: parent
                                source: root.player ? (root.player.trackArtUrl || "") : ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: !root.player || !root.player.trackArtUrl
                                text: "󰝚"
                                color: Theme.faint
                                font.family: Theme.fontMono
                                font.pixelSize: 20
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: root.player ? (root.player.trackTitle || "Nothing playing") : ""
                                color: Theme.fg
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: root.player ? (root.player.trackArtist || "") : ""
                                color: Theme.faint
                                font.family: Theme.font
                                font.pixelSize: 12
                            }
                            Row {
                                spacing: 4
                                Pill {
                                    icon: "󰒮"
                                    onClicked: if (root.player) root.player.previous()
                                }
                                Pill {
                                    icon: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                                    tint: Theme.ac2
                                    active: root.player ? root.player.isPlaying : false
                                    onClicked: if (root.player) root.player.togglePlaying()
                                }
                                Pill {
                                    icon: "󰒭"
                                    onClicked: if (root.player) root.player.next()
                                }
                            }
                        }
                    }
                }

                // ── volume, a real control ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 7
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "VOLUME"
                            color: Theme.faint
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.letterSpacing: 1.1
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
                            color: Theme.dim
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }
                    }
                    Slider {
                        Layout.fillWidth: true
                        value: root.volume
                        tint: root.muted ? Theme.faint : Theme.ac
                        onMoved: (v) => root.setVolume(v)
                    }
                }

                // ── live system ──
                // Gauges answer "right now", the graphs underneath answer
                // "for the last minute". Stacked rather than side by side:
                // a sparkline squeezed into the gap beside two rings is a
                // sliver, and a sliver is not a demonstration of anything.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Meter {
                        Layout.preferredWidth: 88
                        Layout.preferredHeight: 88
                        value: root.cpu
                        tint: root.cpu > 0.85 ? Theme.red : Theme.ac
                        label: Math.round(root.cpu * 100) + "%"
                        caption: "CPU"
                    }
                    Meter {
                        Layout.preferredWidth: 88
                        Layout.preferredHeight: 88
                        value: root.memUsed / root.memTotal
                        tint: Theme.ac2
                        label: (root.memUsed / 1073741824).toFixed(1) + "G"
                        caption: "MEMORY"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 9

                        Repeater {
                            model: [
                                { k: "Total",  v: (root.memTotal / 1073741824).toFixed(1) + " GB" },
                                { k: "In use", v: (root.memUsed / 1073741824).toFixed(1) + " GB" },
                                { k: "Free",   v: ((root.memTotal - root.memUsed) / 1073741824).toFixed(1) + " GB" }
                            ]
                            RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.k
                                    color: Theme.faint
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: modelData.v
                                    color: Theme.dim
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "LAST 60 SECONDS"
                            color: Theme.faint
                            font.family: Theme.font
                            font.pixelSize: 9
                            font.letterSpacing: 1.1
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Row {
                            spacing: 12
                            Row {
                                spacing: 4
                                Rectangle { width: 7; height: 2; radius: 1; color: Theme.ac
                                            anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "cpu"; color: Theme.faint
                                       font.family: Theme.font; font.pixelSize: 10 }
                            }
                            Row {
                                spacing: 4
                                Rectangle { width: 7; height: 2; radius: 1; color: Theme.ac2
                                            anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "mem"; color: Theme.faint
                                       font.family: Theme.font; font.pixelSize: 10 }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        implicitHeight: 76
                        color: Theme.surface2

                        Sparkline {
                            id: cpuGraph
                            anchors.fill: parent
                            anchors.margins: 6
                            stroke: Theme.ac
                        }
                        Sparkline {
                            id: memGraph
                            anchors.fill: parent
                            anchors.margins: 6
                            stroke: Theme.ac2
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.line }

                // ── actions ──
                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: [
                            { icon: "󰍉", tip: "Search",  cmd: "~/.config/themes/launch.sh" },
                            { icon: "󰆍", tip: "Term",    cmd: "alacritty" },
                            { icon: "󰉋", tip: "Files",   cmd: "thunar" },
                            { icon: "󰸉", tip: "Rices",   cmd: "~/.config/themes/picker.sh" },
                            { icon: "󰃟", tip: "Shot",    cmd: "grim -g \"$(slurp)\" - | swappy -f -" },
                            { icon: "󰌾", tip: "Lock",    cmd: "hyprlock" },
                            { icon: "󰜉", tip: "Reload",  cmd: "~/.config/themes/shell.sh restart" },
                            { icon: "󰐥", tip: "Power",   cmd: "~/.config/waybar/scripts/power.sh" }
                        ]
                        Card {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 54
                            color: Theme.surface2
                            radius: Theme.radiusSm
                            property bool hov: false
                            border.color: hov ? Theme.ac : Theme.line
                            Behavior on border.color { ColorAnimation { duration: Theme.quick } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 3
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.icon
                                    color: parent.parent.hov ? Theme.ac : Theme.dim
                                    font.family: Theme.fontMono
                                    font.pixelSize: 16
                                    Behavior on color { ColorAnimation { duration: Theme.quick } }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.tip
                                    color: Theme.faint
                                    font.family: Theme.font
                                    font.pixelSize: 10
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.hov = true
                                onExited: parent.hov = false
                                onClicked: { root.run(modelData.cmd); root.dashOpen = false }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Quickshell " + (Quickshell.env("QS_VERSION") || "") + " · one QML codebase"
                    color: Theme.line
                    font.family: Theme.font
                    font.pixelSize: 10
                }
            }
        }
    }
}

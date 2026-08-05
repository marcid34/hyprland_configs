# Launcher, Dash and shell.qml — the three surfaces.

from string import Template

# ── Launcher ────────────────────────────────────────────────────────────
LAUNCHER = Template("""import QtQuick
import QtQuick.Effects
import Quickshell

// The launcher.
//
// A focusable layer surface running a live query over the desktop entry
// database, with its own keyboard handling and a GPU blur of whatever is
// behind it. Opened from the bar or over IPC.
//
// The motion is the point. Opening runs three things at once — the scrim
// fades, the card rises 18px and scales from 0.97, and the rows stagger in
// 22ms apart. Closing runs one thing, faster. An exit that mirrors the
// entrance feels like the machine is thinking; an exit that gets out of the
// way feels like it already knew.
PanelWindow {
    id: root

    property bool open: false

    visible: open
    focusable: true          // a layer surface that can be typed into
    exclusiveZone: 0
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property string query: ""
    property int selected: 0

    // Subsequence match with positional weighting: every character of the
    // query must appear in order, matches that begin a word beat matches
    // buried mid-token, and an unbroken run beats a scattered one. Cheap
    // enough to re-run on every keystroke over the full entry list.
    function score(name, q) {
        if (q === "") return 1;
        const n = name.toLowerCase(), s = q.toLowerCase();
        let i = 0, hits = 0, streak = 0, best = 0, first = -1;
        for (let c = 0; c < n.length && i < s.length; c++) {
            if (n[c] === s[i]) {
                if (first < 0) first = c;
                hits++; streak++; best = Math.max(best, streak); i++;
            } else streak = 0;
        }
        if (i < s.length) return 0;
        return 1000 - first * 3 + best * 12 + hits;
    }

    readonly property var results: {
        const q = query;
        const out = [];
        for (const a of DesktopEntries.applications.values) {
            if (a.noDisplay) continue;
            const sc = score(a.name || "", q);
            if (sc > 0) out.push({ app: a, score: sc });
        }
        out.sort((x, y) => y.score - x.score
                        || x.app.name.localeCompare(y.app.name));
        return out.slice(0, 7);
    }

    function launch(i) {
        const r = results[i];
        if (r) r.app.execute();
        root.open = false;
    }

    onOpenChanged: {
        if (open) { query = ""; selected = 0; input.forceActiveFocus(); }
    }
    onResultsChanged: if (selected >= results.length) selected = 0

    // Scrim. Clicking it closes — a modal you cannot dismiss by clicking away
    // is the single most common way this kind of surface annoys people.
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: root.open ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: Theme.base; easing.type: Theme.exit }
        }
        MouseArea { anchors.fill: parent; onClicked: root.open = false }
    }

    Surface {
        id: card
        width: 540
        height: col.implicitHeight + Theme.pad * 2
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.24

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.97
        transform: Translate { y: root.open ? 0 : 18 }

        Behavior on opacity {
            NumberAnimation { duration: Theme.base; easing.type: Theme.enter }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.slow; easing.type: Theme.enter }
        }

        Column {
            id: col
            anchors.fill: parent
            anchors.margins: Theme.pad
            spacing: 10

            // ── query ──
            Row {
                width: parent.width
                spacing: 12

                Text {
                    text: "󰍉"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: input
                    width: parent.width - 34
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: 17
                    selectionColor: Theme.accentWash2
                    selectedTextColor: Theme.fg
                    clip: true

                    onTextChanged: { root.query = text; root.selected = 0 }

                    Text {
                        anchors.fill: parent
                        visible: input.text === ""
                        text: "Search"
                        color: Theme.faint
                        font: input.font
                        verticalAlignment: Text.AlignVCenter
                    }

                    Keys.onEscapePressed: root.open = false
                    Keys.onReturnPressed: root.launch(root.selected)
                    Keys.onEnterPressed:  root.launch(root.selected)
                    Keys.onDownPressed: {
                        if (root.results.length)
                            root.selected = (root.selected + 1) % root.results.length
                    }
                    Keys.onUpPressed: {
                        if (root.results.length)
                            root.selected = (root.selected - 1 + root.results.length)
                                            % root.results.length
                    }
                    Keys.onTabPressed: {
                        if (root.results.length)
                            root.selected = (root.selected + 1) % root.results.length
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.bg3
                visible: root.results.length > 0
            }

            // ── results ──
            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: root.results

                    Rectangle {
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: 46
                        radius: Theme.radiusSm
                        color: index === root.selected ? Theme.accentWash
                             : rowMa.containsMouse ? Theme.bg2 : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.fast } }

                        // Staggered entrance. Each row waits index*22ms, which
                        // at seven rows is 154ms of cascade — enough to read as
                        // deliberate, short enough that the last row is still
                        // there before you could have moved to it.
                        opacity: 0
                        transform: Translate { id: rowShift; y: 8 }

                        SequentialAnimation on opacity {
                            running: root.open
                            PauseAnimation { duration: index * 22 }
                            NumberAnimation {
                                to: 1; duration: Theme.base; easing.type: Theme.enter
                            }
                        }
                        SequentialAnimation {
                            running: root.open
                            PauseAnimation { duration: index * 22 }
                            NumberAnimation {
                                target: rowShift; property: "y"; to: 0
                                duration: Theme.slow; easing.type: Theme.enter
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Image {
                                width: 26; height: 26
                                anchors.verticalCenter: parent.verticalCenter
                                source: modelData.app.icon
                                       ? Quickshell.iconPath(modelData.app.icon, true) : ""
                                smooth: true
                                asynchronous: true
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1
                                width: parent.width - 50

                                Text {
                                    text: modelData.app.name || ""
                                    color: Theme.fg
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Text {
                                    visible: text !== ""
                                    text: modelData.app.comment || ""
                                    color: Theme.faint
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }
                        }

                        MouseArea {
                            id: rowMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selected = index
                            onClicked: root.launch(index)
                        }
                    }
                }
            }

            Text {
                visible: root.results.length === 0 && root.query !== ""
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                topPadding: 14
                bottomPadding: 14
                text: "No match"
                color: Theme.faint
                font.family: Theme.font
                font.pixelSize: 13
            }
        }
    }
}
""")

# ── Dash ────────────────────────────────────────────────────────────────
DASH = Template("""import QtQuick
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
""")

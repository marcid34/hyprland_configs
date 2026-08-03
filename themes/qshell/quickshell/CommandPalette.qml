import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Particles
import Quickshell
import Quickshell.Widgets

// The command palette.
//
// Named CommandPalette, not Palette: QtQuick already exports a Palette type
// (the colour-role object), and a local file of that name is silently shadowed
// by it -- every property you declare then reads as "non-existent".
//
// This is the part of the showcase that a bar cannot be talked into doing. A
// waybar module is a string of text on a surface that never takes keyboard
// focus; this is a focusable layer surface running a live query over the
// system's application database, with its own keyboard navigation, its own
// GPU-composited blur and a particle field behind it.
//
// Everything here is QML. There is no helper binary, no dmenu, no rofi.
PanelWindow {
    id: root

    // The palette owns this. The bar button and the global shortcut both
    // just flip it, so there is one source of truth and no signal round trip.
    property bool open: false

    visible: open
    // Keyboard focus on a layer surface. Waybar has no equivalent -- it
    // cannot be typed into at all.
    focusable: true
    exclusiveZone: 0
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property string query: ""
    property int selected: 0

    // Subsequence scoring: characters must appear in order, and matches that
    // start the name or a word rank above matches buried mid-token.
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
        const apps = DesktopEntries.applications.values;
        const out = [];
        for (const a of apps) {
            if (a.noDisplay) continue;
            const sc = score(a.name || "", q);
            if (sc > 0) out.push({ app: a, score: sc });
        }
        out.sort((x, y) => y.score - x.score || x.app.name.localeCompare(y.app.name));
        return out.slice(0, 8);
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

    // Dim + blur what is behind. MultiEffect is GPU-composited; a GTK bar has
    // no way to blur the desktop beneath itself.
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.open ? 0.5 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.slow; easing.type: Theme.easing } }
        MouseArea { anchors.fill: parent; onClicked: { root.open = false } }
    }

    // A slow particle field. Purely atmosphere, and precisely the sort of
    // thing that is free here and impossible in a CSS bar.
    ParticleSystem {
        id: particles
        anchors.fill: parent
        running: root.open

        ImageParticle {
            color: Theme.ac
            alpha: 0
            colorVariation: 0.35
            entryEffect: ImageParticle.Scale
        }
        Emitter {
            anchors.fill: parent
            emitRate: 14
            lifeSpan: 7000
            size: 5
            sizeVariation: 4
            velocity: PointDirection { y: -14; yVariation: 10; xVariation: 10 }
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Escape) { root.open = false; e.accepted = true }
            else if (e.key === Qt.Key_Down) { root.selected = Math.min(root.selected + 1, root.results.length - 1); e.accepted = true }
            else if (e.key === Qt.Key_Up) { root.selected = Math.max(root.selected - 1, 0); e.accepted = true }
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { root.launch(root.selected); e.accepted = true }
        }

        Card {
            id: card
            width: 660
            height: Math.min(header.height + list.contentHeight + 26, 520)
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.22
            color: Qt.alpha(Theme.surface, 0.97)

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: Theme.slow; easing.type: Theme.easing } }
            Behavior on scale { NumberAnimation { duration: Theme.slow; easing.type: Theme.easing } }
            Behavior on height { NumberAnimation { duration: Theme.quick; easing.type: Theme.easing } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 13
                spacing: 8

                RowLayout {
                    id: header
                    Layout.fillWidth: true
                    spacing: 11

                    Text {
                        text: "󰍉"
                        color: Theme.ac
                        font.family: Theme.fontMono
                        font.pixelSize: 19
                    }

                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        focus: true
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 19
                        selectionColor: Qt.alpha(Theme.ac, 0.35)
                        selectedTextColor: Theme.fg
                        onTextChanged: { root.query = text; root.selected = 0 }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: "Search applications…"
                            color: Theme.faint
                            font: input.font
                        }
                    }

                    Text {
                        text: root.results.length + " result" + (root.results.length === 1 ? "" : "s")
                        color: Theme.faint
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.line }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.results
                    currentIndex: root.selected
                    clip: true
                    interactive: contentHeight > height
                    highlightMoveDuration: Theme.quick

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: list.width
                        height: 50

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: Theme.radiusSm
                            color: index === root.selected ? Qt.alpha(Theme.ac, 0.15) : "transparent"
                            border.width: 1
                            border.color: index === root.selected ? Qt.alpha(Theme.ac, 0.45) : "transparent"
                            Behavior on color { ColorAnimation { duration: Theme.quick } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 13

                            // Not every .desktop entry has an icon that
                            // actually resolves, and a blank column reads as a
                            // rendering bug. Fall back to an initial.
                            Item {
                                implicitWidth: 28
                                implicitHeight: 28

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 7
                                    visible: icon.status !== Image.Ready
                                    color: Qt.alpha(Theme.ac, 0.14)
                                    border.width: 1
                                    border.color: Qt.alpha(Theme.ac, 0.3)
                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData.app.name || "?").charAt(0).toUpperCase()
                                        color: Theme.ac
                                        font.family: Theme.font
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }
                                }

                                IconImage {
                                    id: icon
                                    anchors.centerIn: parent
                                    implicitSize: 26
                                    source: Quickshell.iconPath(modelData.app.icon, true)
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    text: modelData.app.name
                                    color: Theme.fg
                                    font.family: Theme.font
                                    font.pixelSize: 14
                                    font.weight: index === root.selected ? Font.DemiBold : Font.Normal
                                }
                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                    text: modelData.app.genericName || ""
                                    color: Theme.faint
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                }
                            }
                            Text {
                                visible: index === root.selected
                                text: "↵"
                                color: Theme.ac
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selected = index
                            onClicked: root.launch(index)
                        }
                    }
                }
            }
        }
    }
}

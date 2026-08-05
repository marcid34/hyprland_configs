//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io

// The rice menu — SUPER+T.
//
// Replaces the rofi picker. rofi could list forty-four names; it could not show
// what any of them look like, and a list of names is the wrong interface for
// choosing between things whose entire difference is visual. Every rice here is
// a tile carrying its own four colours, read from themes/palettes.index.
//
// Rice-agnostic on purpose. It is one program, not a per-profile config, and it
// paints itself in the *active* rice's colours — so the menu you change themes
// with always looks like the theme you are currently on. Those colours come
// from the same index as the tiles, which means a rice added to profiles.list
// and re-indexed appears here with no change to this file.
//
// Launched on demand and exits on selection; it is not a running shell.
ShellRoot {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string themes: home + "/.config/themes"

    // ── model ────────────────────────────────────────────────────────────
    property var rices: []          // [{ name, label, bg, fg, ac, ac2 }]
    property string current: ""
    property string query: ""
    property int selected: 0

    readonly property int columns: 4

    // Palette of the *active* rice, used to paint this menu. Falls back to a
    // neutral dark set for the moment before the index has loaded, so the
    // first frame is never unstyled.
    readonly property var self: {
        for (const r of rices) if (r.name === current) return r;
        return { bg: "#101216", fg: "#e8ecf2", ac: "#6aa6ff", ac2: "#8ad6c0" };
    }

    readonly property color cBg:   self.bg
    readonly property color cFg:   self.fg
    readonly property color cAc:   self.ac
    readonly property color cAc2:  self.ac2
    // Surfaces are derived from the rice's own background rather than being
    // fixed greys, which is what lets one stylesheet sit correctly on both a
    // near-black rice and a paper-white one.
    readonly property bool cLight: cBg.hslLightness > 0.5
    readonly property color cSurface: cLight ? Qt.darker(cBg, 1.04) : Qt.lighter(cBg, 1.55)
    readonly property color cRaised:  cLight ? Qt.darker(cBg, 1.10) : Qt.lighter(cBg, 2.00)
    readonly property color cLine:    cLight ? Qt.darker(cBg, 1.18) : Qt.lighter(cBg, 2.60)
    readonly property color cDim:     cLight ? Qt.lighter(cFg, 1.9) : Qt.darker(cFg, 1.7)
    readonly property color cWash:    Qt.rgba(cAc.r, cAc.g, cAc.b, 0.16)

    readonly property int fast: 110
    readonly property int base: 200
    readonly property int slow: 320

    // ── sources ──────────────────────────────────────────────────────────
    // profiles.list is the registry and fixes the order; palettes.index only
    // supplies colour. A rice missing from the index still lists, in the
    // active rice's colours, rather than vanishing from the menu.
    property var labels: ({})
    property var swatches: ({})

    function rebuild() {
        const out = [];
        for (const name of Object.keys(labels)) {
            const s = swatches[name];
            out.push({
                name: name,
                label: labels[name],
                bg:  s ? s[0] : String(cBg),
                fg:  s ? s[1] : String(cFg),
                ac:  s ? s[2] : String(cAc),
                ac2: s ? s[3] : String(cAc2),
            });
        }
        rices = out;
    }

    FileView {
        path: root.themes + "/profiles.list"
        onLoaded: {
            const m = {};
            for (const line of text().split("\n")) {
                const t = line.trim();
                if (t === "" || t.startsWith("#")) continue;
                const p = t.split("|");
                m[p[0]] = p[1] || p[0];
            }
            root.labels = m;
            root.rebuild();
        }
    }

    FileView {
        path: root.themes + "/palettes.index"
        onLoaded: {
            const m = {};
            for (const line of text().split("\n")) {
                const t = line.trim();
                if (t === "" || t.startsWith("#")) continue;
                const p = t.split("|");
                if (p.length >= 5) m[p[0]] = [p[1], p[2], p[3], p[4]];
            }
            root.swatches = m;
            root.rebuild();
        }
    }

    // `current` is a symlink, which FileView cannot resolve — read it out.
    Process {
        running: true
        command: ["sh", "-c",
                  "basename \"$(readlink " + root.themes + "/current)\" 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.current = text.trim()
        }
    }

    // ── filtering ────────────────────────────────────────────────────────
    function score(name, label, q) {
        if (q === "") return 1;
        const hay = (name + " " + label).toLowerCase();
        const s = q.toLowerCase();
        let i = 0, first = -1, streak = 0, best = 0;
        for (let c = 0; c < hay.length && i < s.length; c++) {
            if (hay[c] === s[i]) {
                if (first < 0) first = c;
                streak++; best = Math.max(best, streak); i++;
            } else streak = 0;
        }
        if (i < s.length) return 0;
        return 1000 - first * 3 + best * 10;
    }

    readonly property var results: {
        const q = query, out = [];
        for (const r of rices) {
            const sc = score(r.name, r.label, q);
            if (sc > 0) out.push({ r: r, s: sc });
        }
        if (q !== "") out.sort((a, b) => b.s - a.s);
        return out.map(x => x.r);
    }

    onResultsChanged: if (selected >= results.length) selected = 0

    function apply(i) {
        const r = results[i];
        if (!r) return;
        // switch.sh restarts the shell, which kills every quickshell process
        // including this one — so detach it and quit rather than waiting on a
        // child that is about to kill its own parent.
        if (r.name !== current)
            Quickshell.execDetached(["sh", "-c", themes + "/switch.sh " + r.name]);
        Quickshell.quit();
    }

    function move(d) {
        if (!results.length) return;
        selected = (selected + d + results.length) % results.length;
    }

    // ── surface ──────────────────────────────────────────────────────────
    PanelWindow {
        id: win

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        focusable: true
        exclusiveZone: 0

        property bool shown: false
        Component.onCompleted: showTimer.start()
        Timer { id: showTimer; interval: 40; onTriggered: win.shown = true }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.cBg.r, root.cBg.g, root.cBg.b, 0.72)
            opacity: win.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: root.base } }
            MouseArea { anchors.fill: parent; onClicked: Quickshell.quit() }
        }

        Rectangle {
            id: card
            width: 880
            height: Math.min(col.implicitHeight + 32, win.height - 120)
            anchors.centerIn: parent
            radius: 22
            color: root.cSurface
            border.width: 1
            border.color: root.cLine
            antialiasing: true

            opacity: win.shown ? 1 : 0
            scale: win.shown ? 1 : 0.975
            transform: Translate { y: win.shown ? 0 : 16 }
            Behavior on opacity { NumberAnimation { duration: root.base; easing.type: Easing.OutQuint } }
            Behavior on scale   { NumberAnimation { duration: root.slow; easing.type: Easing.OutQuint } }

            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 1
                height: 1
                color: root.cLight ? Qt.rgba(0, 0, 0, 0.06) : Qt.rgba(1, 1, 1, 0.08)
            }

            Column {
                id: col
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // ── header ──
                Item {
                    width: parent.width
                    height: 34

                    Text {
                        id: prompt
                        anchors.verticalCenter: parent.verticalCenter
                        text: "rice"
                        color: root.cAc
                        font.family: "Adwaita Sans"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    TextInput {
                        id: input
                        anchors {
                            left: prompt.right; leftMargin: 14
                            right: counter.left; rightMargin: 14
                            verticalCenter: parent.verticalCenter
                        }
                        color: root.cFg
                        font.family: "Adwaita Sans"
                        font.pixelSize: 16
                        selectionColor: root.cWash
                        selectedTextColor: root.cFg
                        clip: true
                        focus: true

                        onTextChanged: { root.query = text; root.selected = 0 }

                        Text {
                            anchors.fill: parent
                            visible: input.text === ""
                            text: "Type to filter"
                            color: root.cDim
                            font: input.font
                            verticalAlignment: Text.AlignVCenter
                        }

                        Keys.onEscapePressed: Quickshell.quit()
                        Keys.onReturnPressed: root.apply(root.selected)
                        Keys.onEnterPressed:  root.apply(root.selected)
                        Keys.onRightPressed:  root.move(1)
                        Keys.onLeftPressed:   root.move(-1)
                        Keys.onDownPressed:   root.move(root.columns)
                        Keys.onUpPressed:     root.move(-root.columns)
                        Keys.onTabPressed:    root.move(1)
                        Keys.onBacktabPressed: root.move(-1)
                    }

                    Text {
                        id: counter
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.results.length + " / " + root.rices.length
                        color: root.cDim
                        font.family: "Adwaita Sans"
                        font.pixelSize: 12
                    }
                }

                Rectangle { width: parent.width; height: 1; color: root.cLine }

                // ── grid ──
                Flickable {
                    // Snapped to a whole number of rows. Clipping a tile
                    // halfway reads as a rendering fault rather than as
                    // "there is more below", which is the opposite of what a
                    // scrollable grid needs to communicate.
                    readonly property int rowH: 74 + grid.spacing
                    readonly property int avail: win.height - 220
                    readonly property int rows: Math.max(1, Math.floor((avail + grid.spacing) / rowH))

                    width: parent.width
                    height: Math.min(grid.implicitHeight, rows * rowH - grid.spacing)
                    contentHeight: grid.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: grid
                        width: parent.width
                        columns: root.columns
                        spacing: 8

                        Repeater {
                            model: root.results

                            Rectangle {
                                id: tile
                                required property var modelData
                                required property int index

                                readonly property bool isSel: index === root.selected
                                readonly property bool isCur: modelData.name === root.current

                                width: (grid.width - grid.spacing * (root.columns - 1))
                                       / root.columns
                                height: 74
                                radius: 14
                                color: isSel ? root.cWash
                                     : tileMa.containsMouse ? root.cRaised : "transparent"
                                border.width: isSel ? 1 : 0
                                border.color: root.cAc

                                Behavior on color { ColorAnimation { duration: root.fast } }

                                scale: tileMa.pressed ? 0.96 : 1
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: root.base
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.5
                                    }
                                }

                                // Staggered entrance, capped: past about a
                                // dozen tiles the cascade stops reading as
                                // deliberate and starts reading as the menu
                                // being slow to open.
                                opacity: 0
                                SequentialAnimation on opacity {
                                    running: win.shown
                                    PauseAnimation { duration: Math.min(index, 12) * 16 }
                                    NumberAnimation {
                                        to: 1; duration: root.base
                                        easing.type: Easing.OutQuint
                                    }
                                }

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 9

                                    Row {
                                        width: parent.width
                                        spacing: 6

                                        Text {
                                            width: parent.width - (tile.isCur ? 16 : 0)
                                            elide: Text.ElideRight
                                            text: tile.modelData.label
                                            color: tile.isSel || tile.isCur
                                                   ? root.cFg : root.cDim
                                            font.family: "Adwaita Sans"
                                            font.pixelSize: 13
                                            font.weight: tile.isCur ? Font.DemiBold : Font.Medium
                                        }

                                        // The rice you are on, marked once. A
                                        // filled dot rather than a word, so it
                                        // cannot collide with a long label.
                                        Rectangle {
                                            visible: tile.isCur
                                            width: 6; height: 6; radius: 3
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: root.cAc
                                        }
                                    }

                                    // Four swatches, in a strip with a hairline
                                    // around it — a rice whose background is
                                    // near the menu's own would otherwise have
                                    // an invisible first swatch.
                                    Rectangle {
                                        width: parent.width
                                        height: 22
                                        radius: 7
                                        color: "transparent"
                                        border.width: 1
                                        border.color: root.cLine
                                        clip: true

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 1

                                            Repeater {
                                                model: [tile.modelData.bg, tile.modelData.fg,
                                                        tile.modelData.ac, tile.modelData.ac2]
                                                Rectangle {
                                                    required property var modelData
                                                    width: parent.width / 4
                                                    height: parent.height
                                                    color: modelData
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: tileMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selected = index
                                    onClicked: root.apply(index)
                                }
                            }
                        }
                    }
                }

                // ── footer ──
                Text {
                    width: parent.width
                    text: "←→↑↓ move    ↵ apply    esc close"
                    color: root.cDim
                    font.family: "Adwaita Sans"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}

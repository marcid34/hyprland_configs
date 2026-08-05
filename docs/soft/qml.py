# The QML shell, as string.Template sources ($token substitution).
#
# One shell design, ten colourings. Every rice in this set ships the same
# component set and the same motion tokens; only Theme.qml differs. That is
# deliberate — the brief was a *feel*, and a feel that changed between rices
# would just be ten different feels.
#
# string.Template rather than str.format because QML is mostly braces.
# Consequence: no bare "$" anywhere below, which rules out JS template
# literals. String concatenation is used instead.

from string import Template

QMLDIR = """module soft
singleton Theme 1.0 Theme.qml
Surface 1.0 Surface.qml
Chip 1.0 Chip.qml
Workspaces 1.0 Workspaces.qml
Ring 1.0 Ring.qml
Slider 1.0 Slider.qml
Launcher 1.0 Launcher.qml
Dash 1.0 Dash.qml
"""

# ── Theme ───────────────────────────────────────────────────────────────
THEME = Template("""pragma Singleton

import QtQuick
import Quickshell   // Singleton is exported here, not by QtQuick

// $name — the whole design system.
//
// $blurb
//
// Colour is the only thing that changes between the ten rices in this set.
// The metrics and the motion below are identical everywhere, because they are
// what the set is actually *for*: a desktop that answers instantly and settles
// softly, whatever colour it happens to be wearing.
Singleton {
    // ── surface ──────────────────────────────────────────────────────────
    readonly property color bg:   "$bg"    // desktop floor
    readonly property color bg1:  "$bg1"   // resting surface
    readonly property color bg2:  "$bg2"   // raised / hovered
    readonly property color bg3:  "$bg3"   // hairline

    // ── ink ──────────────────────────────────────────────────────────────
    readonly property color fg:    "$fg"
    readonly property color fg1:   "$fg1"
    readonly property color dim:   "$dim"
    readonly property color faint: "$faint"

    // ── signal ───────────────────────────────────────────────────────────
    readonly property color accent:  "$accent"
    readonly property color accent2: "$accent2"
    readonly property color red:     "$red"
    readonly property color green:   "$green"
    readonly property color yellow:  "$yellow"

    readonly property bool light: $light_qml

    // Derived tints. Computed rather than hardcoded so a palette edit is one
    // line: every wash, glow and pressed state below follows the accent.
    readonly property color accentWash:  Qt.rgba(accent.r,  accent.g,  accent.b,  0.14)
    readonly property color accentWash2: Qt.rgba(accent.r,  accent.g,  accent.b,  0.24)
    readonly property color accent2Wash: Qt.rgba(accent2.r, accent2.g, accent2.b, 0.14)
    readonly property color redWash:     Qt.rgba(red.r,     red.g,     red.b,     0.16)
    readonly property color scrim:       Qt.rgba(bg.r, bg.g, bg.b, 0.62)

    // The one-pixel line along the top of every surface. On a dark rice it is
    // white at low alpha; on a light one that would be invisible, so it
    // inverts. This is most of why the surfaces read as glass and not as flat
    // fills, and it is the single token that has to know about `light`.
    readonly property color hi: light ? Qt.rgba(0, 0, 0, 0.06)
                                      : Qt.rgba(1, 1, 1, 0.07)

    // ── metric ───────────────────────────────────────────────────────────
    readonly property int barHeight: 40
    readonly property int gap:       10
    readonly property int radius:    18   // island / panel
    readonly property int radiusSm:  12   // nested card
    readonly property int pad:       14

    // ── type ─────────────────────────────────────────────────────────────
    readonly property string font:     "Adwaita Sans"
    readonly property string fontMono: "JetBrainsMono Nerd Font"

    // ── motion ───────────────────────────────────────────────────────────
    // Three durations and three curves, and nothing in the shell is allowed
    // to invent a fourth.
    //
    // The split that matters is enter vs. exit. Things arriving use OutQuint,
    // which covers most of its distance immediately and then eases out — that
    // front-loading is what makes a click feel *answered* rather than
    // animated. Things leaving use OutCubic and a shorter duration, because a
    // slow exit reads as lag on the next thing you do.
    readonly property int fast: 110   // hover, colour
    readonly property int base: 200   // most movement
    readonly property int slow: 320   // panels entering

    readonly property int enter: Easing.OutQuint
    readonly property int exit:  Easing.OutCubic
    // Overshoot for anything that should feel physical: the press bounce and
    // the workspace pill. Kept small — past about 1.6 it stops reading as
    // responsive and starts reading as a toy.
    readonly property int pop:   Easing.OutBack

    function pct(v) { return Math.round(v * 100) + "%" }
}
""")

# ── Surface ─────────────────────────────────────────────────────────────
SURFACE = Template("""import QtQuick

// Every panel, island and card in the shell is one of these.
//
// A fill, a hairline, and a one-pixel highlight along the top edge. The
// highlight is doing the real work: a flat rounded rectangle on a dark
// desktop reads as a hole, and the same rectangle with a lit top edge reads
// as a raised pane. It costs one Rectangle and no shader.
Rectangle {
    id: surface

    property bool hovered: false
    property bool interactive: false

    color: interactive && hovered ? Theme.bg2 : Theme.bg1
    radius: Theme.radius
    border.width: 1
    border.color: Theme.bg3
    antialiasing: true

    Behavior on color { ColorAnimation { duration: Theme.fast } }

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.leftMargin: parent.radius * 0.55
        anchors.rightMargin: parent.radius * 0.55
        anchors.topMargin: 1
        height: 1
        color: Theme.hi
    }
}
""")

# ── Chip ────────────────────────────────────────────────────────────────
CHIP = Template("""import QtQuick

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
""")

# ── Workspaces ──────────────────────────────────────────────────────────
WORKSPACES = Template("""import QtQuick
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
""")

# ── Ring ────────────────────────────────────────────────────────────────
RING = Template("""import QtQuick

// A circular meter, drawn on a Canvas.
//
// Animating `value` directly would step the canvas in whatever increments the
// sampler happens to produce, which looks like stuttering rather than change.
// So the arc reads `shown`, and `shown` is what gets the Behavior — the
// repaint is then always smooth regardless of how coarsely the source ticks.
Item {
    id: ring

    property real value: 0        // 0..1, set by the sampler
    property color tint: Theme.accent
    property string label: ""
    property string caption: ""

    implicitWidth: 78
    implicitHeight: 78

    property real shown: 0
    onValueChanged: shown = value
    Behavior on shown {
        NumberAnimation { duration: Theme.slow; easing.type: Theme.enter }
    }
    onShownChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d");
            const w = width, h = height;
            const cx = w / 2, cy = h / 2;
            const r = Math.min(w, h) / 2 - 5;
            ctx.reset();

            ctx.lineWidth = 5;
            ctx.lineCap = "round";

            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, Math.PI * 2);
            ctx.strokeStyle = Theme.bg3;
            ctx.stroke();

            if (ring.shown > 0.001) {
                ctx.beginPath();
                // Start at 12 o'clock, sweep clockwise.
                ctx.arc(cx, cy, r, -Math.PI / 2,
                        -Math.PI / 2 + Math.PI * 2 * Math.min(1, ring.shown));
                ctx.strokeStyle = ring.tint;
                ctx.stroke();
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ring.label
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ring.caption
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 9
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 0.8
        }
    }
}
""")

# ── Slider ──────────────────────────────────────────────────────────────
SLIDER = Template("""import QtQuick

// A drag-and-click slider.
//
// Two details make it feel like hardware rather than a form control:
//
//   The track grows from 6px to 10px on hover, so the target announces itself
//   before you commit to it.
//
//   The fill follows the pointer with no animation *while dragging* (any
//   easing there reads as the control lagging your hand), and animates only
//   when something else moves it — a volume key, another app. `pressed` is
//   what switches between the two.
Item {
    id: slider

    property real value: 0        // 0..1
    property color tint: Theme.accent
    property string icon: ""

    signal moved(real v)

    implicitHeight: 26
    implicitWidth: 200

    function setFromX(px) {
        const usable = track.width;
        if (usable <= 0) return;
        slider.moved(Math.max(0, Math.min(1, px / usable)));
    }

    Row {
        anchors.fill: parent
        spacing: 10

        Text {
            visible: slider.icon !== ""
            text: slider.icon
            color: slider.tint
            font.family: Theme.fontMono
            font.pixelSize: 14
            width: 18
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - (slider.icon !== "" ? 28 : 0)
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: ma.containsMouse || ma.pressed ? 10 : 6
                radius: height / 2
                color: Theme.bg3

                Behavior on height {
                    NumberAnimation { duration: Theme.fast; easing.type: Theme.enter }
                }

                Rectangle {
                    height: parent.height
                    width: Math.max(parent.height, parent.width * Math.max(0, Math.min(1, slider.value)))
                    radius: height / 2
                    color: slider.tint

                    // No easing under the pointer; easing everywhere else.
                    Behavior on width {
                        enabled: !ma.pressed
                        NumberAnimation { duration: Theme.base; easing.type: Theme.enter }
                    }
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: (m) => slider.setFromX(m.x)
                onPositionChanged: (m) => { if (pressed) slider.setFromX(m.x) }
            }
        }
    }
}
""")

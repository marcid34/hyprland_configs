pragma Singleton

import QtQuick
import Quickshell   // Singleton is exported here, not by QtQuick

// ember — the whole design system.
//
// Banked heat. Amber falling into rose, nothing fully cooled.
//
// Colour is the only thing that changes between the ten rices in this set.
// The metrics and the motion below are identical everywhere, because they are
// what the set is actually *for*: a desktop that answers instantly and settles
// softly, whatever colour it happens to be wearing.
Singleton {
    // ── surface ──────────────────────────────────────────────────────────
    readonly property color bg:   "#120d0b"    // desktop floor
    readonly property color bg1:  "#1b1512"   // resting surface
    readonly property color bg2:  "#241c18"   // raised / hovered
    readonly property color bg3:  "#322722"   // hairline

    // ── ink ──────────────────────────────────────────────────────────────
    readonly property color fg:    "#f7ede6"
    readonly property color fg1:   "#dcc9bd"
    readonly property color dim:   "#ab9184"
    readonly property color faint: "#7a655a"

    // ── signal ───────────────────────────────────────────────────────────
    readonly property color accent:  "#ff9d4d"
    readonly property color accent2: "#ff6f88"
    readonly property color red:     "#ff6f88"
    readonly property color green:   "#b8d18a"
    readonly property color yellow:  "#ff9d4d"

    readonly property bool light: false

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

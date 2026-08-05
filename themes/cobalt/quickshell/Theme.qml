pragma Singleton

import QtQuick
import Quickshell   // Singleton is exported here, not by QtQuick

// cobalt — the whole design system.
//
// Deep water and luminous azure. Cold, clean, wide awake.
//
// Colour is the only thing that changes between the ten rices in this set.
// The metrics and the motion below are identical everywhere, because they are
// what the set is actually *for*: a desktop that answers instantly and settles
// softly, whatever colour it happens to be wearing.
Singleton {
    // ── surface ──────────────────────────────────────────────────────────
    readonly property color bg:   "#090d15"    // desktop floor
    readonly property color bg1:  "#101724"   // resting surface
    readonly property color bg2:  "#16202f"   // raised / hovered
    readonly property color bg3:  "#222e42"   // hairline

    // ── ink ──────────────────────────────────────────────────────────────
    readonly property color fg:    "#e9f0fa"
    readonly property color fg1:   "#c0cddd"
    readonly property color dim:   "#8496ab"
    readonly property color faint: "#58687c"

    // ── signal ───────────────────────────────────────────────────────────
    readonly property color accent:  "#4d9dff"
    readonly property color accent2: "#78e2ff"
    readonly property color red:     "#ff8080"
    readonly property color green:   "#66dfa8"
    readonly property color yellow:  "#ffcc70"

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

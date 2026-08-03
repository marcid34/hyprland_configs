pragma Singleton

import QtQuick
import Quickshell   // Singleton lives here, not in QtQuick

// One place for every colour, radius and duration in the shell.
//
// Deliberately small. A showcase that needs forty tokens to describe itself is
// showing off the wrong thing; this is the whole design system, and every
// surface below is built from it.
Singleton {
    // ── colour ───────────────────────────────────────────────────────────
    readonly property color bg:       "#0a0c0f"
    readonly property color surface:  "#111419"
    readonly property color surface2: "#171b22"
    readonly property color line:     "#222833"
    readonly property color fg:       "#eef2f7"
    readonly property color dim:      "#93a0b0"
    readonly property color faint:    "#5c6673"

    readonly property color ac:   "#5b9dff"
    readonly property color ac2:  "#4ade80"
    readonly property color warn: "#fbbf24"
    readonly property color red:  "#f87171"

    // ── metric ───────────────────────────────────────────────────────────
    readonly property int barHeight: 40
    readonly property int gap:       10
    readonly property int radius:    14
    readonly property int radiusSm:  9
    readonly property int pad:       14

    // ── type ─────────────────────────────────────────────────────────────
    readonly property string font:     "Adwaita Sans"
    readonly property string fontMono: "JetBrainsMono Nerd Font"

    // ── motion ───────────────────────────────────────────────────────────
    // Two durations and one curve. Everything that moves uses these, which is
    // most of why the result feels coherent rather than busy.
    readonly property int quick: 140
    readonly property int slow:  260
    readonly property int easing: Easing.OutCubic

    function pct(v) { return Math.round(v * 100) + "%" }
}

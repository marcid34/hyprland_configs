pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The live biome's palette, read from the rice rather than baked in here.
//
// themes/current/quickshell.json is a symlink chain ending in
// modes/<biome>/quickshell.json, so flipping the biome repoints it and
// FileView's watcher repaints the shell without a restart.
Singleton {
    id: root

    // Sensible defaults so the shell still draws if the file is missing or
    // momentarily half-written during a biome switch.
    property string label: "calamity"
    property string other: ""
    property color bg: "#191029"
    property color bg1: "#1f1533"
    property color bg2: "#2b1e47"
    property color bg3: "#3b2a60"
    property color bg4: "#4a3578"
    property color fg: "#e2d8f5"
    property color fg1: "#c3b3e4"
    property color dim: "#7d6ba8"
    property color ac: "#9d7cd8"
    property color ac2: "#7bd88f"
    property color red: "#d2688f"
    property color yellow: "#d8b96a"
    property color slot: "#241a3d"
    property color slotEdge: "#0d0817"

    // Terraria's UI is built out of chunky repeated units, so the whole shell
    // is sized off one slot rather than a pile of unrelated magic numbers.
    readonly property int unit: 54
    readonly property int edge: 3
    readonly property string fontMain: "Pixelify Sans"
    readonly property string fontLabel: "Silkscreen"

    FileView {
        path: Quickshell.env("HOME") + "/.config/themes/current/quickshell.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const p = JSON.parse(text());
                for (const k of ["label", "other", "bg", "bg1", "bg2", "bg3", "bg4",
                                 "fg", "fg1", "dim", "ac", "ac2", "red", "yellow",
                                 "slot", "slotEdge"]) {
                    if (p[k] !== undefined) root[k] = p[k];
                }
            } catch (e) {
                // A malformed file should leave the shell readable, not blank.
                console.warn("calamity: bad quickshell.json:", e);
            }
        }
    }
}

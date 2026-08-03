pragma Singleton

import QtQuick

// The shell's icon set, hand-drawn on a 12x12 grid.
//
// Legend, matching PixelIcon.qml:
//   '.' transparent   'O' outline   'F' biome accent
//   'W' light         'G' secondary  'D' dim
//
// Shapes are deliberately blunt. At twelve pixels across, a detailed drawing
// turns to mush; a bold silhouette with a full outline still reads.
QtObject {
    // Application grid — nine slots, which is what a launcher is here.
    readonly property var launcher: [
        "............",
        ".OOO.OOO.OOO",
        ".OFO.OFO.OFO",
        ".OOO.OOO.OOO",
        "............",
        ".OOO.OOO.OOO",
        ".OFO.OFO.OFO",
        ".OOO.OOO.OOO",
        "............",
        ".OOO.OOO.OOO",
        ".OFO.OFO.OFO",
        ".OOO.OOO.OOO"
    ]

    // A terminal: window frame, a prompt caret, a cursor block.
    readonly property var terminal: [
        "OOOOOOOOOOOO",
        "O..........O",
        "O.WW.......O",
        "O..WW......O",
        "O.WW.......O",
        "O..........O",
        "O..FFFF....O",
        "O..........O",
        "O..........O",
        "OOOOOOOOOOOO",
        "............",
        "............"
    ]

    // A chest, because in Terraria that is where your files live.
    readonly property var files: [
        "............",
        ".OOOOOOOOOO.",
        ".OFFFFFFFFO.",
        ".OFFFFFFFFO.",
        ".OOOOGGOOOO.",
        ".OFFFGGFFFO.",
        ".OFFFGGFFFO.",
        ".OFFFFFFFFO.",
        ".OFFFFFFFFO.",
        ".OOOOOOOOOO.",
        "............",
        "............"
    ]

    // A seed sprouting — the biome switch.
    readonly property var biome: [
        "............",
        "........OOO.",
        ".....OOOGGGO",
        "...OOGGGGGGO",
        "..OGGGGGGGO.",
        "..OGGGGGGO..",
        "..OGGGGGO...",
        "..OOGGGO....",
        "...OFOO.....",
        "...OFO......",
        "..OOFOO.....",
        "............"
    ]

    // Four swatches — the rice picker.
    readonly property var rices: [
        "............",
        ".OOOOOOOOOO.",
        ".OFFFFOGGGGO",
        ".OFFFFOGGGGO",
        ".OFFFFOGGGGO",
        ".OOOOOOOOOOO",
        ".OWWWWODDDDO",
        ".OWWWWODDDDO",
        ".OWWWWODDDDO",
        ".OOOOOOOOOO.",
        "............",
        "............"
    ]

    // A padlock.
    readonly property var lock: [
        "............",
        "....OOOO....",
        "...OO..OO...",
        "...OO..OO...",
        "..OOOOOOOO..",
        "..OFFFFFFO..",
        "..OFFOOFFO..",
        "..OFFOOFFO..",
        "..OFFFFFFO..",
        "..OOOOOOOO..",
        "............",
        "............"
    ]

    // A camera — region screenshot.
    readonly property var shot: [
        "............",
        "....OOO.....",
        ".OOOOOOOOOO.",
        ".OFFFFFFFFO.",
        ".OFOOOOOOFO.",
        ".OFOWWWWOFO.",
        ".OFOWWWWOFO.",
        ".OFOOOOOOFO.",
        ".OFFFFFFFFO.",
        ".OOOOOOOOOO.",
        "............",
        "............"
    ]

    // The power glyph, drawn rather than typed.
    readonly property var power: [
        ".....FF.....",
        ".....FF.....",
        "..FF.FF.FF..",
        ".FF..FF..FF.",
        ".FF.......FF",
        "FF.........F",
        "FF.........F",
        "FF.........F",
        ".FF.......FF",
        "..FF.....FF.",
        "...FFFFFFF..",
        "............"
    ]

    // Bar affordances: the side-menu handle, pointing whichever way it opens.
    readonly property var chevronRight: [
        "............",
        "...OO.......",
        "...OFO......",
        "...OFFO.....",
        "...OFFFO....",
        "...OFFFFO...",
        "...OFFFO....",
        "...OFFO.....",
        "...OFO......",
        "...OO.......",
        "............",
        "............"
    ]

    readonly property var chevronLeft: [
        "............",
        ".......OO...",
        "......OFO...",
        ".....OFFO...",
        "....OFFFO...",
        "...OFFFFO...",
        "....OFFFO...",
        ".....OFFO...",
        "......OFO...",
        ".......OO...",
        "............",
        "............"
    ]
}

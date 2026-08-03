#!/usr/bin/env python3
"""Build the calamity rice's pixel cursors, one full set per biome.

The pointer is Terraria's own arrowhead, transcribed by hand off an in-game
screenshot: 8x7 pixels, one pixel of outline all the way round, tip at the
top-left. It is a shape and two colours, not an extracted asset, but it is
Re-Logic's design and worth naming as such.

Terraria has no I-beam or resize cursor, so the rest of the set is drawn in
the same language -- 1px outline, flat fill, a lighter inner highlight -- and
sized to sit alongside the pointer. Shipping the whole set matters: a theme
with only left_ptr in it falls through to whatever it inherits the moment you
hover a text field, which reads as "the cursor didn't change".

Terraria lets the player choose the cursor colour, so tinting per biome is in
keeping: purple in Corruption, the game's own red in Crimson.

Nothing is antialiased and every size is an integer multiple of the original
grid, so edges stay square however far it scales.

Writes the Xcursor binary format directly -- no xcursorgen, no root:

    ~/.local/share/icons/Terraria-<Biome>/
        cursors/<name>   (+ every alias apps actually ask for, as symlinks)
        index.theme

Usage:  ./make-cursor.py [--preview DIR]
"""
import os
import struct
import sys

# '.' transparent   'O' outline   'F' biome fill   'W' highlight   'G' second
OUTLINE = (0x0B, 0x0D, 0x11)

BIOMES = {
    "Corruption": dict(fill=(0x7A, 0x3C, 0xA8), hi=(0xB0, 0x7C, 0xE0),
                       second=(0x7B, 0xD8, 0x8F)),
    "Crimson":    dict(fill=(0xA8, 0x26, 0x45), hi=(0xE0, 0x5A, 0x78),
                       second=(0xE8, 0xB1, 0x3D)),
}

# ── the shapes ────────────────────────────────────────────────────────────
# name: (grid, hotspot, [x11 and css aliases])

# Every grid fits the pointer's footprint -- 9x9 at most.
#
# This matters more than it looks: one scale factor is applied to all of them,
# so a 15-row I-beam next to an 8-row arrow renders nearly twice the height.
# Drawing them all to the same box is what keeps the set feeling like one
# cursor rather than a pointer plus a pile of oversized icons. MAX_GRID below
# enforces it.
ARROW = [
    "KK.......",
    "KWKKK....",
    ".KWFFKK..",
    ".KWFFFFK.",
    ".KFFFKK..",
    "..KFKK...",
    "..KFK....",
    "...K.....",
]

IBEAM = [
    "OOOOO",
    "OFFFO",
    "OOFOO",
    ".OFO.",
    ".OFO.",
    ".OFO.",
    "OOFOO",
    "OFFFO",
    "OOOOO",
]

HAND = [
    "..OO....",
    ".OWFO...",
    ".OWFOOO.",
    ".OWFOFFO",
    "OOWFFFFO",
    "OFFFFFFO",
    "OFFFFFFO",
    ".OFFFFO.",
    "..OOOO..",
]

HOURGLASS = [
    "OOOOOOO",
    "OWWWWWO",
    ".OGGGO.",
    "..OGO..",
    "..OGO..",
    ".OGGGO.",
    "OGGGGGO",
    "OWWWWWO",
    "OOOOOOO",
]

CROSSHAIR = [
    "...OOO...",
    "...OFO...",
    "...OFO...",
    "OOOOFOOOO",
    "OFFFFFFFO",
    "OOOOFOOOO",
    "...OFO...",
    "...OFO...",
    "...OOO...",
]

RESIZE_H = [
    "..O...O..",
    ".OO...OO.",
    "OFOOOOOFO",
    "OFFFFFFFO",
    "OFOOOOOFO",
    ".OO...OO.",
    "..O...O..",
]

RESIZE_V = [
    "...O...",
    "..OFO..",
    ".OFFFO.",
    "OOOFOOO",
    "..OFO..",
    "OOOFOOO",
    ".OFFFO.",
    "..OFO..",
    "...O...",
]

RESIZE_FDIAG = [
    "OOOOO....",
    "OFFFO....",
    "OFFFO....",
    "OOFFOO...",
    "..OFFFO..",
    "...OFFOO.",
    "....OFFFO",
    "....OFFFO",
    "....OOOOO",
]

RESIZE_BDIAG = [
    "....OOOOO",
    "....OFFFO",
    "....OFFFO",
    "...OOFFOO",
    "..OFFFO..",
    ".OOFFO...",
    "OFFFO....",
    "OFFFO....",
    "OOOOO....",
]

MOVE = [
    "....O....",
    "...OFO...",
    "..OFFFO..",
    "OOOOFOOOO",
    "OFFFFFFFO",
    "OOOOFOOOO",
    "..OFFFO..",
    "...OFO...",
    "....O....",
]

FORBIDDEN = [
    "..OOOOO..",
    ".OFFFFFO.",
    "OFFFFFFFO",
    "OFOOOOOFO",
    "OOOOOOOOO",
    "OFOOOOOFO",
    "OFFFFFFFO",
    ".OFFFFFO.",
    "..OOOOO..",
]

GRABBING = [
    ".OO.OO.O.",
    "OFFOFFOFO",
    "OFFFFFFFO",
    "OFFFFFFFO",
    "OFFFFFFFO",
    "OFFFFFFFO",
    ".OFFFFFO.",
    "..OFFFO..",
    "...OOO...",
]

# Aliases are the whole point of shipping a set: toolkits ask by both the
# legacy X11 names and the CSS names, and Qt/GTK also use hashed names for a
# few. A shape with no alias for what an app asks for is a shape that app
# never shows.
SHAPES = {
    "left_ptr": (ARROW, (0, 0), [
        "default", "arrow", "top_left_arrow", "left_arrow",
        "9d800788f1b08800ae810202380a0822"]),
    "xterm": (IBEAM, (2, 4), ["text", "ibeam"]),
    "hand2": (HAND, (3, 1), [
        "pointer", "hand1", "hand", "pointing_hand", "grab", "openhand",
        "e29285e634086352946a0e7090d73106"]),
    "watch": (HOURGLASS, (3, 4), ["wait"]),
    "left_ptr_watch": (HOURGLASS, (3, 4), [
        "progress", "half-busy", "00000000000000020006000e7e9ffc3f",
        "3ecb610c1bf2410f44200f48c40d3599"]),
    "crosshair": (CROSSHAIR, (4, 4), ["cross", "tcross", "cell"]),
    "sb_h_double_arrow": (RESIZE_H, (4, 3), [
        "ew-resize", "h_double_arrow", "col-resize", "split_h",
        "028006030e0e7ebffc7f7070c0600140", "14fef782d02440884392942c11205230"]),
    "sb_v_double_arrow": (RESIZE_V, (3, 4), [
        "ns-resize", "v_double_arrow", "row-resize", "split_v",
        "00008160000006810000408080010102", "2870a09082c103050810ffdffffe0204"]),
    "bottom_right_corner": (RESIZE_FDIAG, (4, 4), [
        "nwse-resize", "size_fdiag", "top_left_corner",
        "c7088f0f3e6c8088236ef8e1e3e70000", "38c5dff7c7b8962045400281044508d2"]),
    "bottom_left_corner": (RESIZE_BDIAG, (4, 4), [
        "nesw-resize", "size_bdiag", "top_right_corner",
        "fcf1c3c7cd4491d801f1e1c78f100000", "60c0e6ba2a1b47cec1cf29be7dc9a55e"]),
    "fleur": (MOVE, (4, 4), ["move", "all-scroll", "size_all", "dnd-move"]),
    "crossed_circle": (FORBIDDEN, (4, 4), [
        "not-allowed", "no-drop", "forbidden", "dnd-none",
        "03b6e0fcb3499374a867c041f52298f0"]),
    # A drag in progress is a closed hand, not the move compass -- aliasing
    # `grabbing` onto fleur would make every drag look like a window move.
    "grabbing": (GRABBING, (4, 4), [
        "closedhand", "dnd-grabbing", "fcf21c00b30f7e3f83fe0dfd12e71cff"]),
}


# A shape bigger than this renders visibly larger than the pointer, because
# one scale factor is applied to every grid. A hotspot outside the grid puts
# the click point somewhere the cursor is not being drawn. Both are silent
# failures at runtime, so they are caught here instead.
MAX_GRID = 9

for _n, (_g, _hot, _al) in SHAPES.items():
    _w = max(len(r) for r in _g)
    _h = len(_g)
    assert all(len(r) == _w for r in _g), f"{_n}: ragged grid"
    assert _w <= MAX_GRID and _h <= MAX_GRID, f"{_n}: {_w}x{_h} exceeds {MAX_GRID}"
    assert 0 <= _hot[0] < _w and 0 <= _hot[1] < _h, f"{_n}: hotspot {_hot} outside grid"

INHERITS = "Adwaita"
# The pointer grid is 8px tall, so a "24px" cursor wants a 3x upscale, not 1x.
SCALES = [(3, 24), (4, 32), (6, 48), (8, 64), (12, 96)]


def bitmap(grid, scale, fill, hi, second):
    gh, gw = len(grid), max(len(r) for r in grid)
    w, h = gw * scale, gh * scale
    px = bytearray(w * h * 4)
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            if ch in ("K", "O"):
                r, g, b = OUTLINE
            elif ch == "W":
                r, g, b = hi
            elif ch == "G":
                r, g, b = second
            else:
                r, g, b = fill
            for dy in range(scale):
                for dx in range(scale):
                    o = ((y * scale + dy) * w + (x * scale + dx)) * 4
                    px[o:o + 4] = bytes((b, g, r, 0xFF))     # BGRA
    return w, h, bytes(px)


def xcursor(frames):
    """frames: [(nominal, w, h, xhot, yhot, bgra)] -> Xcursor file bytes."""
    ntoc = len(frames)
    header = struct.pack("<4sIII", b"Xcur", 16, 0x00010000, ntoc)
    toc, chunks = b"", b""
    pos = len(header) + ntoc * 12
    for nominal, w, h, xh, yh, px in frames:
        toc += struct.pack("<III", 0xFFFD0002, nominal, pos)
        chunk = struct.pack("<IIII", 36, 0xFFFD0002, nominal, 1)
        chunk += struct.pack("<IIIII", w, h, xh, yh, 0)
        chunk += px
        chunks += chunk
        pos += len(chunk)
    return header + toc + chunks


def build(biome, spec, preview=None):
    theme = f"Terraria-{biome}"
    root = os.path.expanduser(f"~/.local/share/icons/{theme}")
    curs = os.path.join(root, "cursors")
    os.makedirs(curs, exist_ok=True)

    made = 0
    for name, (grid, hot, aliases) in SHAPES.items():
        frames = []
        for scale, nominal in SCALES:
            w, h, px = bitmap(grid, scale, spec["fill"], spec["hi"], spec["second"])
            frames.append((nominal, w, h, hot[0] * scale, hot[1] * scale, px))
        with open(os.path.join(curs, name), "wb") as fh:
            fh.write(xcursor(frames))
        made += 1
        for alias in aliases:
            link = os.path.join(curs, alias)
            if os.path.lexists(link):
                os.remove(link)
            os.symlink(name, link)

        if preview:
            os.makedirs(preview, exist_ok=True)
            w, h, px = bitmap(grid, 4, spec["fill"], spec["hi"], spec["second"])
            _png(w, h, px, os.path.join(preview, f"{theme}-{name}.png"))

    with open(os.path.join(root, "index.theme"), "w") as fh:
        fh.write(f"[Icon Theme]\nName={theme}\n"
                 f"Comment=Terraria pixel cursors for the calamity rice ({biome})\n"
                 f"Inherits={INHERITS}\n")

    return theme, root, made, len(os.listdir(curs))


def _png(w, h, bgra, dest):
    import zlib
    rows = b""
    for y in range(h):
        row = bgra[y * w * 4:(y + 1) * w * 4]
        rows += b"\x00" + bytes(
            c for i in range(0, len(row), 4)
            for c in (row[i + 2], row[i + 1], row[i], row[i + 3]))

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    open(dest, "wb").write(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(rows))
        + chunk(b"IEND", b""))


if __name__ == "__main__":
    preview = None
    if "--preview" in sys.argv:
        preview = sys.argv[sys.argv.index("--preview") + 1]
    for biome, spec in BIOMES.items():
        name, root, shapes, files = build(biome, spec, preview)
        print(f"{name:<22} {shapes:2d} shapes, {files:3d} files -> {root}")

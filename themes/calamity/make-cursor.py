#!/usr/bin/env python3
"""Build the calamity rice's pixel cursors, one per biome.

The pointer below is Terraria's own arrowhead, transcribed by hand off an
in-game screenshot: 8x7 pixels, one pixel of outline all the way round, tip at
the top-left. It is a shape and eight colours, not an extracted asset, but it
is Re-Logic's design and worth naming as such rather than passing off as
original.

Terraria lets the player choose the cursor colour, so tinting it per biome is
in keeping: purple in Corruption, the game's own red in Crimson.

Nothing here is antialiased and every size is an integer multiple of the
original grid, so the edges stay square however far it scales up.

Writes the Xcursor binary format directly -- no xcursorgen, no root:

    ~/.local/share/icons/Terraria-<Biome>/
        cursors/left_ptr  (+ the usual aliases as symlinks)
        index.theme       (Inherits= a normal theme, so any shape this shell
                           does not draw falls back instead of vanishing)

Usage:  ./make-cursor.py [--preview DIR]
"""
import os
import struct
import sys

# The arrowhead Terraria actually draws, read pixel-for-pixel off a screenshot
# of the game (the reference was 2x, so this is the de-scaled 9x8 original).
# Squat, tip at the top-left, one pixel of outline the whole way round.
#
# '.' transparent   'K' outline   'F' biome fill   'W' highlight
GLYPH = [
    "KK.......",
    "KWKKK....",
    ".KWFFKK..",
    ".KWFFFFK.",
    ".KFFFKK..",
    "..KFKK...",
    "..KFK....",
    "...K.....",
]
HOTSPOT = (0, 0)

# Terraria lets the player pick the cursor colour, so tinting it per biome is
# in keeping rather than a liberty. Crimson uses the game's own default red,
# sampled from the reference; Corruption is its purple counterpart.
OUTLINE = (0x0B, 0x0D, 0x11)
BIOMES = {
    "Corruption": dict(fill=(0x7A, 0x3C, 0xA8), hi=(0xB0, 0x7C, 0xE0)),
    "Crimson":    dict(fill=(0xA8, 0x26, 0x45), hi=(0xE0, 0x5A, 0x78)),
}

# Every shape this theme does not draw is inherited from here.
INHERITS = "Adwaita"

# Names apps actually ask for. left_ptr is the real file; the rest are links
# to it, which is what normal cursor themes do for the pointer family.
ALIASES = ["default", "arrow", "top_left_arrow", "left_arrow",
           "9d800788f1b08800ae810202380a0822"]

# The glyph is only 8px tall, so a "24px" cursor wants a 3x upscale, not 1x.
SCALES = [(3, 24), (4, 32), (6, 48), (8, 64), (12, 96)]  # (pixel scale, nominal size)


def bitmap(scale, fill, hi):
    """-> (w, h, bytes) in BGRA, integer-scaled with no interpolation."""
    gh, gw = len(GLYPH), len(GLYPH[0])
    w, h = gw * scale, gh * scale
    px = bytearray(w * h * 4)
    for y, row in enumerate(GLYPH):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            if ch == "K":
                r, g, b = OUTLINE
                a = 0xFF
            elif ch == "W":
                r, g, b = hi
                a = 0xFF
            else:
                r, g, b = fill
                a = 0xFF
            for dy in range(scale):
                for dx in range(scale):
                    o = ((y * scale + dy) * w + (x * scale + dx)) * 4
                    px[o:o + 4] = bytes((b, g, r, a))     # BGRA
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

    frames = []
    for scale, nominal in SCALES:
        w, h, px = bitmap(scale, spec["fill"], spec["hi"])
        frames.append((nominal, w, h, HOTSPOT[0] * scale, HOTSPOT[1] * scale, px))

    main = os.path.join(curs, "left_ptr")
    with open(main, "wb") as fh:
        fh.write(xcursor(frames))

    for name in ALIASES:
        link = os.path.join(curs, name)
        if os.path.lexists(link):
            os.remove(link)
        os.symlink("left_ptr", link)

    with open(os.path.join(root, "index.theme"), "w") as fh:
        fh.write(f"[Icon Theme]\nName={theme}\n"
                 f"Comment=Pixel pointer for the calamity rice ({biome})\n"
                 f"Inherits={INHERITS}\n")

    if preview:
        os.makedirs(preview, exist_ok=True)
        w, h, px = bitmap(4, spec["fill"], spec["hi"])
        _png(w, h, px, os.path.join(preview, f"{theme}.png"))

    return theme, root


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
        name, root = build(biome, spec, preview)
        print(f"{name:<22} -> {root}")

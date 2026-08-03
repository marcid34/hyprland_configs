"""Regenerate docs/ image assets: wallpaper thumbnails and palette strips.

Run after adding a rice or changing a wallpaper:

    python3 docs/collect.py > /tmp/rices.json
    python3 docs/gen_assets.py /tmp/rices.json

A rice with more than one mode gets one thumbnail split between its modes and
one palette strip carrying both, so it stays a single card in the README and
in RICES.html while still showing what the switch actually does.
"""
import json, os, subprocess, sys

rices = json.load(open(sys.argv[1]))
REPO = os.path.expanduser("~/.config/rices/hyprland_configs")
THUMBS = os.path.join(REPO, "docs", "thumbs")
PALETTES = os.path.join(REPO, "docs", "palettes")
os.makedirs(THUMBS, exist_ok=True)
os.makedirs(PALETTES, exist_ok=True)

W = 560          # thumbnail width
SW, SH = 24, 24  # one palette swatch


def wall_path(rice, fname):
    return os.path.join(REPO, "wallpapers", rice, fname)


def run(args):
    subprocess.run(args, check=True)


for r in rices:
    rid = r["id"]

    # ── thumbnail ────────────────────────────────────────────────────────
    if r.get("mode_data"):
        # One tile per mode, side by side, each cropped to its share of the
        # frame so the pair reads as a single 3:2 image rather than two.
        tiles, n = [], len(r["mode_data"])
        for m in r["mode_data"]:
            src = next((wall_path(rid, w["file"]) for w in m["wallpapers"]
                        if os.path.isfile(wall_path(rid, w["file"]))), None)
            if src:
                tiles.append(src)
        if tiles:
            each = W // len(tiles)
            args = ["magick"]
            for t in tiles:
                args += ["(", t, "-resize", f"{W}x", "-gravity", "center",
                         "-crop", f"{each}x{int(W / 1.5)}+0+0", "+repage", ")"]
            args += ["+append", "-strip", "-quality", "80",
                     os.path.join(THUMBS, f"{rid}.jpg")]
            run(args)
    else:
        src = next((wall_path(rid, w["file"]) for w in r["wallpapers"]
                    if os.path.isfile(wall_path(rid, w["file"]))), None)
        if src:
            run(["magick", src, "-strip", "-resize", f"{W}x",
                 "-quality", "80", os.path.join(THUMBS, f"{rid}.jpg")])

    # ── palette strip ────────────────────────────────────────────────────
    if r.get("mode_data"):
        cols = [c["hex"][:7] for m in r["mode_data"] for c in m["palette"]]
    else:
        cols = [c["hex"][:7] for c in r["palette"]]
    if cols:
        args = ["magick"]
        for c in cols:
            args += ["(", "-size", f"{SW}x{SH}", f"xc:{c}", ")"]
        args += ["+append", "-strip", os.path.join(PALETTES, f"{rid}.png")]
        run(args)

print("thumbs:  ", len(os.listdir(THUMBS)))
print("palettes:", len(os.listdir(PALETTES)))

#!/usr/bin/env python3
"""Download the ten chosen wallpapers at full resolution and write credits.

Indices refer to the contact sheets built by wall2.py / wall3.py — the choice
was made by looking at them, not by score. The colour scoring only ever
narrowed the pool.
"""

import json
import os
import shutil
import sys
import time
import urllib.request

OUT = "/home/birch/.config/rices/hyprland_configs/wallpapers"

# rice -> (which sheet, index on it, one line on why)
CHOICE = {
    "halcyon":  (2, 6, "Coral dune under a deep teal sky — the accent colour, at scale."),
    "vellum":   (1, 1, "Sage paper folds on warm cream. Light without being a white screen."),
    "cobalt":   (1, 0, "Blue bloom on deep navy."),
    "orchid":   (1, 3, "Violet bloom, soft-focus edges."),
    "seafoam":  (2, 2, "Aurora over a fjord: deep teal water, mint light."),
    "graphite": (1, 3, "The same bloom in greyscale — no hue anywhere in it."),
    "ember":    (1, 6, "Warm light through arches, everything else in shadow."),
    "glacier":  (1, 4, "Blue ink diffusing into white."),
    "nocturne": (1, 0, "A moonlit swell. Dark, and not heavy."),
    "matcha":   (1, 4, "One green-yellow ribbon across dark olive."),
}


def main():
    c1 = json.load(open("/tmp/ricegen/candidates.json"))
    c2 = json.load(open("/tmp/ricegen/candidates2.json"))
    rows = []

    for name, (sheet, idx, why) in CHOICE.items():
        src = (c1 if sheet == 1 else c2)[name][idx]

        d = os.path.join(OUT, name)
        # Clear the first pass's mistakes rather than leaving two images in a
        # directory the wallpaper file points into by name.
        if os.path.isdir(d):
            shutil.rmtree(d)
        os.makedirs(d, exist_ok=True)

        ext = os.path.splitext(src["path"])[1] or ".jpg"
        dest = os.path.join(d, name + ext)

        req = urllib.request.Request(
            src["path"], headers={"User-Agent": "rice-picker/final"})
        with urllib.request.urlopen(req, timeout=180) as r, open(dest, "wb") as f:
            f.write(r.read())

        mb = os.path.getsize(dest) / 1e6
        print("%-9s %-8s %-11s %5.1fMB  %s" % (name, src["id"], src["res"], mb, dest))
        rows.append((name, os.path.basename(dest), src["id"], src["url"],
                     src["res"], why))
        time.sleep(0.6)

    json.dump(rows, open("/tmp/ricegen/credits.json", "w"), indent=2)


if __name__ == "__main__":
    main()

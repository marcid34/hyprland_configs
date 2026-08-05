#!/usr/bin/env python3
"""Round two: candidate *thumbnails* only, for visual review.

The first pass sorted by relevance on mood words and returned stock photos and
clip art — "warm gradient" matches a Pantone swatch card perfectly well. Two
changes fix it:

  sorting=favorites   what the site's users actually put on a desktop, rather
                      than what a text index thinks the words mean.
  colors=<hex>        wallhaven's own dominant-colour filter, off their fixed
                      palette, instead of scoring the colours after the fact.

This downloads thumbnails and builds one contact sheet per rice. Nothing is
committed from here — the full image is fetched only for the chosen id.
"""

import json
import os
import subprocess
import sys
import time
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palettes import RICES  # noqa: E402

API = "https://wallhaven.cc/api/v1/search"
TMP = "/tmp/ricegen/cand"

# Nearest colour on wallhaven's fixed filter palette, plus a query that biases
# towards clean desktop art rather than photography of objects.
PICK = {
    "halcyon":  ("ff6600", "minimal abstract"),
    "vellum":   ("cccccc", "minimal texture"),
    "cobalt":   ("0066cc", "minimal abstract"),
    "orchid":   ("663399", "minimal abstract"),
    "seafoam":  ("66cccc", "minimal abstract"),
    "graphite": ("000000", "minimal dark abstract"),
    "ember":    ("ff9900", "minimal abstract"),
    "glacier":  ("cccccc", "minimal light abstract"),
    "nocturne": ("333399", "minimal night"),
    "matcha":   ("669900", "minimal abstract"),
}


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "rice-picker/2"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())


def search(color, q, page=1):
    params = {
        "colors": color,
        "categories": "100",
        "purity": "100",
        "atleast": "2560x1440",
        "ratios": "16x9,16x10",
        "sorting": "favorites",
        "order": "desc",
        "page": str(page),
    }
    if q:
        params["q"] = q
    return fetch(API + "?" + urllib.parse.urlencode(params)).get("data", [])


def main():
    os.makedirs(TMP, exist_ok=True)
    manifest = {}

    for rice in RICES:
        name = rice["name"]
        color, q = PICK[name]

        cands = {}
        # Colour + query first; then colour alone, which is a much larger pool
        # and is what fills in when the query is too narrow.
        for qq in (q, ""):
            for page in (1, 2):
                try:
                    for c in search(color, qq, page):
                        cands[c["id"]] = c
                except Exception as e:
                    print("  ! %s %r p%d: %s" % (name, qq, page, e), file=sys.stderr)
                time.sleep(1.3)
            if len(cands) >= 16:
                break

        picks = list(cands.values())[:8]
        manifest[name] = [
            {"id": c["id"], "path": c["path"], "res": c["resolution"],
             "url": c["short_url"], "colors": c["colors"]}
            for c in picks
        ]

        tiles = []
        for i, c in enumerate(picks):
            dest = os.path.join(TMP, "%s_%d_%s.jpg" % (name, i, c["id"]))
            try:
                req = urllib.request.Request(
                    c["thumbs"]["large"], headers={"User-Agent": "rice-picker/2"})
                with urllib.request.urlopen(req, timeout=60) as r, open(dest, "wb") as f:
                    f.write(r.read())
                # Number each tile so the contact sheet can be referred to by
                # index when choosing.
                subprocess.run(
                    ["magick", dest, "-resize", "340x191^", "-gravity", "center",
                     "-extent", "340x191", "-gravity", "northwest",
                     "-fill", "white", "-undercolor", "#000000c0",
                     "-pointsize", "20", "-annotate", "+6+6", str(i), dest],
                    check=True)
                tiles.append(dest)
            except Exception as e:
                print("  ! thumb %s: %s" % (c["id"], e), file=sys.stderr)
            time.sleep(0.4)

        if tiles:
            sheet = "/tmp/ricegen/sheet_%s.png" % name
            subprocess.run(["magick", "montage"] + tiles +
                           ["-tile", "4x2", "-geometry", "+3+3", sheet], check=True)
            print("%-9s %d candidates -> %s" % (name, len(tiles), sheet))

    with open("/tmp/ricegen/candidates.json", "w") as f:
        json.dump(manifest, f, indent=2)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Emit the ten rices.

One design, ten colourings. Every file each rice needs is written from the
templates in this directory, so the set cannot drift: fixing a bug in the
launcher fixes it in all ten, and a palette edit is one line in palettes.py.
"""

import glob
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import conf                                            # noqa: E402
import qml, qml2, qml3                                 # noqa: E402
from palettes import RICES, ansi, hexa, rgba           # noqa: E402

REPO = "/home/birch/.config/rices/hyprland_configs"
THEMES = os.path.join(REPO, "themes")
WALLS = os.path.join(REPO, "wallpapers")


def wallpaper_path(name):
    hits = sorted(glob.glob(os.path.join(WALLS, name, name + ".*")))
    if not hits:
        raise SystemExit("no wallpaper for %s" % name)
    return hits[0]


def vars_for(r):
    name = r["name"]
    light = r["light"]

    v = dict(r)
    v.update(
        light_qml="true" if light else "false",
        light_lua="true" if light else "false",

        # waybar CSS wants rgba(); the islands are translucent so the wallpaper
        # shows through them the way it does under the real shell.
        bg1_a=rgba(r["bg1"], 0.90 if not light else 0.94),
        accent_wash=rgba(r["accent"], 0.14),
        red_wash=rgba(r["red"], 0.16),

        # hyprland/hyprlock want 8-digit hex with no leading '#'
        accent_hex=hexa(r["accent"], 1.0).lstrip("#"),
        accent2_hex=hexa(r["accent2"], 1.0).lstrip("#"),
        bg3_hex=hexa(r["bg3"], 1.0).lstrip("#"),
        bg1_hex_a=hexa(r["bg1"], 0.91).lstrip("#"),
        fg_hex=hexa(r["fg"], 1.0).lstrip("#"),
        dim_hex=hexa(r["dim"], 1.0).lstrip("#"),
        faint_hex=hexa(r["faint"], 1.0).lstrip("#"),
        red_hex=hexa(r["red"], 1.0).lstrip("#"),
        shadow_hex=hexa("#000000", 0.42 if not light else 0.16).lstrip("#"),

        # pango markup in hyprlock uses ## for a literal '#'
        faint_bare=r["faint"].lstrip("#"),
        red_bare=r["red"].lstrip("#"),

        ansi_accent=ansi(r["accent"]),
        ansi_accent2=ansi(r["accent2"]),
        ansi_dim=ansi(r["dim"]),

        rule="  " + "\\u2500" * 30,
        blurb_short=r["blurb"].split(".")[0],

        icon_theme="breeze" if light else "breeze-dark",

        # A light rice cannot take the same dimming as a dark one: the same
        # dim_strength that reads as depth on near-black reads as dirt on
        # near-white, and a translucent terminal over a bright wallpaper stops
        # being readable well before a dark one does.
        term_opacity="0.96" if light else "0.92",
        inactive_opacity="0.97" if light else "0.94",
        dim_strength="0.04" if light else "0.10",
        lock_brightness="0.86" if light else "0.62",

        wallpaper_path=wallpaper_path(name),
    )
    return v


FILES = [
    ("waybar.jsonc",    conf.WAYBAR_JSON),
    ("waybar.css",      conf.WAYBAR_CSS),
    ("mako.conf",       conf.MAKO),
    ("rofi.rasi",       conf.ROFI),
    ("hypr.lua",        conf.HYPR),
    ("alacritty.toml",  conf.ALACRITTY),
    ("nvim.lua",        conf.NVIM),
    ("fastfetch.jsonc", conf.FASTFETCH),
    ("hyprlock.conf",   conf.HYPRLOCK),
    ("wallpaper",       conf.WALLPAPER),
]

QML_FILES = [
    ("Theme.qml",      qml.THEME),
    ("Surface.qml",    qml.SURFACE),
    ("Chip.qml",       qml.CHIP),
    ("Workspaces.qml", qml.WORKSPACES),
    ("Ring.qml",       qml.RING),
    ("Slider.qml",     qml.SLIDER),
    ("Launcher.qml",   qml2.LAUNCHER),
    ("Dash.qml",       qml2.DASH),
    ("shell.qml",      qml3.SHELL),
]


def main():
    written = 0
    for r in RICES:
        name = r["name"]
        v = vars_for(r)
        d = os.path.join(THEMES, name)
        qd = os.path.join(d, "quickshell")
        os.makedirs(qd, exist_ok=True)

        for fn, tpl in FILES:
            with open(os.path.join(d, fn), "w") as f:
                f.write(tpl.substitute(v))
            written += 1

        for fn, tpl in QML_FILES:
            with open(os.path.join(qd, fn), "w") as f:
                f.write(tpl.substitute(v))
            written += 1

        with open(os.path.join(qd, "qmldir"), "w") as f:
            f.write(qml.QMLDIR)
        # Every rice in this set is a quickshell rice. SUPER+R still wants a
        # launcher for the fallback path, and rofi is the one program every
        # profile in the repo can already count on.
        with open(os.path.join(d, "shell.components"), "w") as f:
            f.write("quickshell\n")
        with open(os.path.join(d, "launcher"), "w") as f:
            f.write("rofi\n")
        with open(os.path.join(d, "about"), "w") as f:
            f.write(r["blurb"] + "\n")
        written += 4

        print("%-9s -> %s" % (name, d))

    print("\n%d files" % written)


if __name__ == "__main__":
    main()

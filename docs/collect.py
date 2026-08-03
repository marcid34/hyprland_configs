"""Collect per-rice metadata into JSON for the overview doc.

Everything here is read out of the rice's own files -- the prose each themed
file carries in its header, the palette rofi.rasi declares, the shell and
launcher the rice asks for. Nothing about a rice's character is invented here.
"""
import json, os, re

THEMES = os.path.expanduser("~/.config/themes")

order, labels = [], {}
for line in open(os.path.join(THEMES, "profiles.list")):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    parts = line.split("|")
    order.append(parts[0])
    labels[parts[0]] = parts[1] if len(parts) > 1 else parts[0]

# "arctic — waybar", "Mac OS X — Alacritty": a file title, not a description.
TITLE = re.compile(r"^.+\s[—-]\s*(waybar|alacritty|rofi|menubar|taskbar|dock)\s*$",
                   re.I)
SKIP = ("shell:", "imported by", "transparency echoes", "all nine element",
        "unnamed from", "one per line", "text uses", "back to the")

def describe(path):
    """The header prose, unwrapped, trimmed to its first two sentences."""
    if not os.path.exists(path):
        return ""
    lines = []
    for i, ln in enumerate(open(path, encoding="utf-8", errors="replace")):
        if i > 12:
            break
        raw = ln.strip()
        if raw.startswith(("{", "*/")) or (raw.startswith("*") and raw.endswith("{")):
            break
        if raw and not raw.startswith(("/*", "*", "#")):
            break                                  # past the header comment
        s = re.sub(r"^/?\*+\s?|^#\s?|\s*\*/\s*$", "", raw).strip()
        if not s or TITLE.match(s):
            continue
        if len(re.findall(r"#[0-9a-fA-F]{6}", s)) >= 2:      # a palette dump
            continue
        if s.lower().startswith(SKIP):
            continue
        lines.append(s)
    text = re.sub(r"\s+", " ", " ".join(lines)).strip()
    parts = re.split(r"(?<=[.!?])\s+", text)
    return " ".join(parts[:2]).strip()

def colours(rice, sub=""):
    """Named colours, in declared order, from the rofi theme's `*  { }` block."""
    p = os.path.join(THEMES, rice, sub, "rofi.rasi")
    if not os.path.exists(p):
        return []
    txt = open(p, encoding="utf-8", errors="replace").read()
    m = re.search(r"\n\*\s*\{(.*?)\}", txt, re.S)
    if not m:
        return []
    seen, out = set(), []
    for name, hexv in re.findall(r"([a-z0-9]+)\s*:\s*(#[0-9a-fA-F]{6,8})", m.group(1)):
        if name in seen:
            continue
        seen.add(name)
        out.append({"name": name, "hex": hexv})
    return out

def one(path):
    try:
        return open(path, encoding="utf-8", errors="replace").read().strip()
    except OSError:
        return ""

def wallpapers(rice, sub=""):
    shots, trans = [], ""
    for ln in one(os.path.join(THEMES, rice, sub, "wallpaper")).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        if ln.startswith("transition="):
            trans = ln.split("=", 1)[1]
            continue
        out, _, path = ln.rpartition("=")
        shots.append({"output": out or "all", "file": os.path.basename(path)})
    return shots, trans

def luminance(hexcol):
    h = hexcol.lstrip("#")[:6]
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    f = lambda c: c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4
    return .2126 * f(r) + .7152 * f(g) + .0722 * f(b)

rices = []
for r in order:
    d = os.path.join(THEMES, r)
    if not os.path.isdir(d):
        continue
    # A rice with more than one palette can't be summarised by any single
    # themed file's header, so it may state its own line in `about`.
    about = re.sub(r"\s+", " ", one(os.path.join(d, "about"))).strip()
    desc = (about
            or describe(os.path.join(d, "waybar.css"))
            or describe(os.path.join(d, "alacritty.toml"))
            or describe(os.path.join(d, "rofi.rasi")))
    modes_dir = os.path.join(d, "modes")
    modes = sorted(n for n in os.listdir(modes_dir)
                   if os.path.isdir(os.path.join(modes_dir, n))
                   and not os.path.islink(os.path.join(modes_dir, n))) \
        if os.path.isdir(modes_dir) else []
    # A multi-mode rice's root files are symlinks through modes/current, so
    # reading them would capture whatever biome happens to be live and make
    # the docs change under you. Read the modes themselves instead, and let
    # the first one stand for the rice.
    mode_data = []
    for mo in modes:
        sub = os.path.join("modes", mo)
        mode_data.append({
            "name": mo,
            "palette": colours(r, sub),
            "wallpapers": wallpapers(r, sub)[0],
            "transition": wallpapers(r, sub)[1],
        })
    if mode_data:
        pal = mode_data[0]["palette"]
        walls = mode_data[0]["wallpapers"]
        trans = mode_data[0]["transition"]
    else:
        pal = colours(r)
        walls, trans = wallpapers(r)
    m = re.search(r'font:\s*"([^"]+)"', one(os.path.join(d, "rofi.rasi")))
    rices.append({
        "id": r,
        "label": labels.get(r, r),
        "desc": desc,
        "shell": ", ".join(one(os.path.join(d, "shell.components")).split()) or "none",
        "launcher": one(os.path.join(d, "launcher")) or "rofi",
        "modes": modes,
        "mode_data": mode_data,
        "cursor": one(os.path.join(d, "cursor")).splitlines()[-1].strip()
                  if os.path.exists(os.path.join(d, "cursor")) else "",
        "font": m.group(1) if m else "",
        "wallpapers": walls,
        "transition": trans,
        # first colour declared in the block is the background, in both the
        # bg/bg1 and the base/surface naming conventions these themes use
        "light": bool(pal) and luminance(pal[0]["hex"]) > 0.4,
        "palette": pal,
    })

print(json.dumps(rices, indent=1, ensure_ascii=False))

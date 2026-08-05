# Ten new rices. Shared design language, ten different temperatures.
#
# The brief: soft, modern, animation-forward. Low-contrast chrome so the
# *content* carries the contrast; one vivid accent per rice and one supporting
# hue beside it; nothing pure black and nothing pure white, because a flat #000
# under a blurred surface reads as a hole rather than a depth.
#
# Token roles are fixed across all ten so one QML shell, one waybar stylesheet
# and one rofi theme can be written once and re-coloured ten times:
#
#   bg    the desktop floor            fg     primary text
#   bg1   a resting surface            fg1    secondary text
#   bg2   a raised/hovered surface     dim    labels, metadata
#   bg3   hairline borders             faint  disabled, ghost text
#
# accent  the rice's signal colour — focus rings, active workspace, cursor
# accent2 a neighbouring hue, used only where two states must be told apart

RICES = [
    dict(
        name="halcyon", label="halcyon", light=False,
        blurb="Warm charcoal and coral. Soft light, hard edges nowhere.",
        bg="#0f0e11", bg1="#17151b", bg2="#1f1c25", bg3="#2b2733",
        fg="#f4f0f5", fg1="#cdc5d1", dim="#9a90a3", faint="#6b6275",
        accent="#ff8f6e", accent2="#ffbfa0",
        red="#ff7a7a", green="#8fd9a8", yellow="#ffc978",
        blue="#8fb8ff", magenta="#d9a2ff", cyan="#7fd8e0",
    ),
    dict(
        name="vellum", label="vellum", light=True,
        blurb="Warm paper and sage ink. A light rice that is not a white screen.",
        bg="#f6f2ea", bg1="#fffdf7", bg2="#efe9dd", bg3="#ded6c6",
        fg="#2c2823", fg1="#4d463d", dim="#7d7466", faint="#a89e8d",
        accent="#6d8f63", accent2="#b38a52",
        red="#b5524a", green="#6d8f63", yellow="#b38a52",
        blue="#4f7a94", magenta="#8a6a94", cyan="#4f8a86",
    ),
    dict(
        name="cobalt", label="cobalt", light=False,
        blurb="Deep water and luminous azure. Cold, clean, wide awake.",
        bg="#090d15", bg1="#101724", bg2="#16202f", bg3="#222e42",
        fg="#e9f0fa", fg1="#c0cddd", dim="#8496ab", faint="#58687c",
        accent="#4d9dff", accent2="#78e2ff",
        red="#ff8080", green="#66dfa8", yellow="#ffcc70",
        blue="#4d9dff", magenta="#b98cff", cyan="#78e2ff",
    ),
    dict(
        name="orchid", label="orchid", light=False,
        blurb="Plum dusk and lilac light. Soft focus with a bright edge.",
        bg="#110d17", bg1="#191323", bg2="#221a30", bg3="#2f2440",
        fg="#f2ecf8", fg1="#d5c8e2", dim="#a292b4", faint="#6f6382",
        accent="#c294ff", accent2="#ff9fd8",
        red="#ff8ba0", green="#93e0b8", yellow="#f5cc85",
        blue="#9db4ff", magenta="#c294ff", cyan="#8fdcf0",
    ),
    dict(
        name="seafoam", label="seafoam", light=False,
        blurb="Deep teal and mint spray. Quiet until something happens.",
        bg="#071310", bg1="#0d1c18", bg2="#132621", bg3="#1d352e",
        fg="#e4f4ef", fg1="#bcdcd2", dim="#7fa89d", faint="#547a70",
        accent="#4fe3b4", accent2="#6fd6f5",
        red="#ff8b8b", green="#4fe3b4", yellow="#ffd28a",
        blue="#6fd6f5", magenta="#c8a6ff", cyan="#6fd6f5",
    ),
    dict(
        name="graphite", label="graphite", light=False,
        blurb="Neutral to the point of silence, with one warm signal in it.",
        bg="#0a0a0b", bg1="#121214", bg2="#1a1a1d", bg3="#26262a",
        fg="#eeeef0", fg1="#c6c6ca", dim="#8d8d94", faint="#5e5e66",
        accent="#f0b64a", accent2="#e6e6ea",
        red="#e88b8b", green="#a8c69a", yellow="#f0b64a",
        blue="#9fb4d4", magenta="#c2a6cc", cyan="#93c4c8",
    ),
    dict(
        name="ember", label="ember", light=False,
        blurb="Banked heat. Amber falling into rose, nothing fully cooled.",
        bg="#120d0b", bg1="#1b1512", bg2="#241c18", bg3="#322722",
        fg="#f7ede6", fg1="#dcc9bd", dim="#ab9184", faint="#7a655a",
        accent="#ff9d4d", accent2="#ff6f88",
        red="#ff6f88", green="#b8d18a", yellow="#ff9d4d",
        blue="#9fb6e0", magenta="#e295c8", cyan="#86ccc4",
    ),
    dict(
        name="glacier", label="glacier", light=True,
        blurb="Cool glass and ice blue. The bright rice, with the glare taken out.",
        bg="#eef2f7", bg1="#ffffff", bg2="#e4ebf3", bg3="#d3dde9",
        fg="#1a2431", fg1="#3a4859", dim="#6b7c90", faint="#97a6b7",
        accent="#2f7fd8", accent2="#3fb0c4",
        red="#c4514f", green="#3f8f6b", yellow="#b5822c",
        blue="#2f7fd8", magenta="#8256b8", cyan="#3fb0c4",
    ),
    dict(
        name="nocturne", label="nocturne", light=False,
        blurb="Indigo night, periwinkle light. Dark without being heavy.",
        bg="#0a0b13", bg1="#11131e", bg2="#171a28", bg3="#232739",
        fg="#eaecf8", fg1="#c8cce4", dim="#9096b4", faint="#626883",
        accent="#8c9cff", accent2="#b9a4ff",
        red="#ff8b9e", green="#7fdfae", yellow="#f6cd83",
        blue="#8c9cff", magenta="#b9a4ff", cyan="#7fd4ee",
    ),
    dict(
        name="matcha", label="matcha", light=False,
        blurb="Soft olive under green light. Organic, low, and very calm.",
        bg="#0c0f0b", bg1="#141911", bg2="#1b2117", bg3="#272f20",
        fg="#eaf0e3", fg1="#ccd6c0", dim="#97a389", faint="#68735c",
        accent="#a9d84c", accent2="#6fd39c",
        red="#f08b7f", green="#a9d84c", yellow="#e6c65c",
        blue="#8fc0d8", magenta="#c0a3e0", cyan="#6fd39c",
    ),
]


def hexa(color, alpha):
    """'#rrggbb' + 0..1 -> '#rrggbbaa'. Hyprland and hyprlock want the alpha
    inline; keeping the conversion in one place stops rounding drift between
    the files that use it."""
    return "%s%02x" % (color, max(0, min(255, round(alpha * 255))))


def rgba(color, alpha):
    """'#rrggbb' + 0..1 -> 'rgba(r, g, b, a)' for GTK/CSS."""
    c = color.lstrip("#")
    r, g, b = (int(c[i:i + 2], 16) for i in (0, 2, 4))
    return "rgba(%d, %d, %d, %.2f)" % (r, g, b, alpha)


def ansi(color):
    """'#rrggbb' -> '38;2;r;g;b' for fastfetch."""
    c = color.lstrip("#")
    r, g, b = (int(c[i:i + 2], 16) for i in (0, 2, 4))
    return "38;2;%d;%d;%d" % (r, g, b)

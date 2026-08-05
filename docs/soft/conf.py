# Everything that is not QML: the twelve files switch.sh requires of a rice.

from string import Template

# ── waybar ──────────────────────────────────────────────────────────────
# Every rice in this set runs quickshell. waybar is the fallback switch.sh
# substitutes on a machine without it — so it ships the same palette and the
# same island geometry, and a machine missing quickshell still gets the rice
# rather than an unstyled bar.
WAYBAR_JSON = Template("""// $name — waybar
//
// Fallback bar. This rice's shell is quickshell; switch.sh drops back to
// waybar when quickshell is not installed, and a rice with no waybar config
// would leave that machine with no bar at all.
{
  "name": "$name",
  "layer": "top",
  "position": "top",
  "height": 38,
  "margin-top": 10,
  "margin-left": 10,
  "margin-right": 10,
  "spacing": 4,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["mpris", "tray", "pulseaudio", "network", "battery"],

  "hyprland/workspaces": {
    "format": "{icon}",
    "format-icons": { "default": "\\u25cf", "active": "\\u25cf", "empty": "\\u25cb" },
    "on-click": "activate",
    "persistent-workspaces": { "*": 6 }
  },
  "hyprland/window": {
    "format": "{title}",
    "max-length": 42,
    "separate-outputs": true,
    "rewrite": { "": "Desktop" }
  },
  "clock": {
    "interval": 10,
    "format": "{:%H:%M   \\u00b7   %a %d %b}",
    "tooltip-format": "<tt>{calendar}</tt>",
    "calendar": { "mode": "month", "format": { "today": "<b>{}</b>" } }
  },
  "mpris": {
    "format": "{status_icon} {title}",
    "max-length": 26,
    "status-icons": { "playing": "\\u25b8", "paused": "\\u2016", "stopped": "\\u25a0" }
  },
  "tray": { "icon-size": 15, "spacing": 8 },
  "pulseaudio": {
    "format": "{icon} {volume}%",
    "format-muted": "\\u00d7 muted",
    "scroll-step": 3,
    "format-icons": { "headphone": "\\u25d1", "default": ["\\u25cb", "\\u25d1", "\\u25cf"] },
    "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  },
  "network": {
    "interval": 5,
    "format-wifi": "\\u25b4 {signalStrength}%",
    "format-ethernet": "\\u25ac",
    "format-disconnected": "\\u25b5",
    "tooltip-format-wifi": "<b>{essid}</b>\\n{signalStrength}%  \\u00b7  {ipaddr}"
  },
  "battery": {
    "interval": 30,
    "states": { "warning": 25, "critical": 12 },
    "format": "{capacity}%",
    "format-charging": "\\u2191 {capacity}%",
    "tooltip-format": "{timeTo}"
  }
}
""")

WAYBAR_CSS = Template("""/* $name — waybar
 *
 * Fallback bar for a machine without quickshell. Same palette, same radius and
 * the same three-island split as the real shell, so the rice still reads as
 * itself if it is ever used.
 */

* {
  font-family: "Adwaita Sans", "FreeSerif", sans-serif;
  font-size: 13px;
  font-weight: 500;
  min-height: 0;
}

window#waybar {
  background: transparent;
  color: $fg;
}

/* The three groups are the islands. Each gets its own fill, hairline and
 * radius rather than the window having one — that is the whole look. */
.modules-left, .modules-center, .modules-right {
  background: $bg1_a;
  border: 1px solid $bg3;
  border-radius: 18px;
  padding: 0 6px;
  margin: 0 2px;
}

#workspaces { background: transparent; padding: 0 2px; }
#workspaces button {
  color: $faint;
  background: transparent;
  padding: 0 5px;
  margin: 4px 1px;
  border: none;
  border-radius: 999px;
  transition: color 200ms ease, background-color 110ms ease;
}
#workspaces button.empty { color: $faint; }
#workspaces button.visible { color: $dim; }
#workspaces button.active {
  color: $accent;
  background: $accent_wash;
}
#workspaces button:hover { background: $bg2; color: $fg1; }

#window { color: $dim; padding: 0 10px; }
#window.empty { color: $faint; }

#clock {
  color: $fg;
  font-weight: 600;
  padding: 0 14px;
  letter-spacing: 0.2px;
}

#mpris, #tray, #pulseaudio, #network, #battery {
  color: $fg1;
  background: transparent;
  padding: 2px 10px;
  margin: 4px 1px;
  border-radius: 999px;
  transition: background-color 110ms ease, color 110ms ease;
}
#mpris:hover, #pulseaudio:hover, #network:hover, #battery:hover {
  background: $bg2;
  color: $fg;
}
#mpris { color: $accent2; }
#pulseaudio.muted { color: $faint; }
#battery.warning { color: $yellow; }
#battery.critical { color: $red; background: $red_wash; }
#battery.charging { color: $green; }

tooltip {
  background: $bg1;
  border: 1px solid $bg3;
  border-radius: 12px;
  color: $fg1;
}
tooltip label { color: $fg1; padding: 4px; }
""")

# ── mako ────────────────────────────────────────────────────────────────
MAKO = Template("""# $name — mako
# $blurb
#
# Rounded to the shell's nested-card radius rather than its island radius: a
# notification is a card that arrives, not a panel that lives there.
anchor=top-right
layer=top
outer-margin=62,10,10,10
margin=8
padding=14,17
width=380
height=170
border-size=1
border-radius=12
font=Adwaita Sans 12
markup=1
format=<b>%s</b>\\n%b
text-alignment=left
background-color=$bg1_a
text-color=$fg
border-color=$bg3
progress-color=over $bg2
icons=1
max-icon-size=32
icon-location=left
default-timeout=5000
ignore-timeout=0
max-visible=5
group-by=app-name
actions=1
history=1
on-button-left=dismiss
on-button-right=dismiss-group
on-button-middle=invoke-default-action

[urgency=low]
text-color=$dim
border-color=$bg3
default-timeout=3000

[urgency=normal]
text-color=$fg
border-color=$bg3
default-timeout=5000

[urgency=critical]
text-color=$fg
border-color=$red
progress-color=over $red
default-timeout=0

[mode=do-not-disturb]
invisible=1

[mode=do-not-disturb urgency=critical]
invisible=0
""")

# ── rofi ────────────────────────────────────────────────────────────────
ROFI = Template("""/* $name — rofi
 *
 * SUPER+R. The shell's own launcher (SUPER+SPACE) is the one built for this
 * rice; this is the same palette and the same geometry so the two do not read
 * as belonging to different desktops.
 */
configuration {
  modes: "drun,run";
  show-icons: true;
  icon-theme: "$icon_theme";
  drun-display-format: "{name}";
  display-drun: "apps";
  display-run: "run";
  drun-match-fields: "name,generic,exec,keywords";
}
* { bg:$bg; bg1:$bg1; bg2:$bg2; bg3:$bg3;
     fg:$fg; fg1:$fg1; dim:$dim; faint:$faint;
     ac:$accent; ac2:$accent2; red:$red;
     background-color: transparent; text-color: @fg1;
     font: "Adwaita Sans 12"; }
window { width: 540px; background-color: @bg1; border: 1px;
          border-color: @bg3; border-radius: 18px; padding: 0; }
mainbox { children: [ inputbar, listview ]; spacing: 0; }
inputbar { children: [ prompt, entry ]; padding: 16px 20px; spacing: 12px;
            border: 0 0 1px 0; border-color: @bg3; }
prompt { text-color: @ac; }
entry { placeholder: "Search"; placeholder-color: @faint; vertical-align: 0.5; }
listview { lines: 7; columns: 1; padding: 10px; spacing: 2px;
            scrollbar: false; fixed-height: false; }
element { padding: 10px 14px; spacing: 12px;
           border-radius: 12px; cursor: pointer; }
element normal.normal, element alternate.normal {
  background-color: transparent; text-color: @fg1; }
element normal.active, element alternate.active {
  background-color: transparent; text-color: @ac2; }
element normal.urgent, element alternate.urgent {
  background-color: transparent; text-color: @red; }
element selected.normal, element selected.active {
  background-color: @ac; text-color: @bg; }
element selected.urgent { background-color: @red; text-color: @bg; }
element-icon { size: 22px; vertical-align: 0.5; }
element-text { vertical-align: 0.5; text-color: inherit; }
""")

# ── hyprland ────────────────────────────────────────────────────────────
# The compositor half of the feel. Windows use a spring; everything else uses
# a front-loaded bezier. Same split as Theme.qml, for the same reason.
HYPR = Template("""-- $name — Hyprland
-- $blurb
--
-- speed is a DURATION in ds (1ds = 100ms): higher is slower.
--
-- Windows get a spring and everything else gets a front-loaded bezier. That
-- is the same enter/exit split the shell uses: a window appearing is a
-- physical event and should overshoot slightly, while a workspace slide is
-- navigation and should simply be over.
return {
    general = {
        gaps_in = 5, gaps_out = 12,
        border_size = 2,
        col = { active_border = "rgba($accent_hex)",
                 inactive_border = "rgba($bg3_hex)" },
    },
    decoration = {
        rounding = 14, rounding_power = 2.6,
        active_opacity = 1.0, inactive_opacity = $inactive_opacity,
        dim_inactive = true, dim_strength = $dim_strength,
        shadow = { enabled = true,
                    range = 24, render_power = 3,
                    color = "rgba($shadow_hex)" },
        blur = { enabled = true,
                  size = 8, passes = 3, vibrancy = 0.19,
                  new_optimizations = true, ignore_opacity = true },
    },
    curves = {
        -- Mirrors Theme.qml: `enter` is front-loaded, `exit` is plain ease.
        { name = "enter", type = "bezier", points = { {0.16, 1}, {0.3, 1} } },
        { name = "exit",  type = "bezier", points = { {0.33, 1}, {0.68, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "spring", type = "spring", mass = 1, stiffness = 340,
           dampening = 26 },
    },
    animations = {
        { leaf = "global",     enabled = true, speed = 2, bezier = "enter" },
        { leaf = "border",     enabled = true, speed = 3, bezier = "enter" },
        { leaf = "windows",    enabled = true, speed = 2, spring = "spring" },
        { leaf = "windowsIn",  enabled = true, speed = 2, spring = "spring",
           style = "popin 92%" },
        { leaf = "windowsOut", enabled = true, speed = 1, bezier = "exit",
           style = "popin 94%" },
        { leaf = "fade",       enabled = true, speed = 1, bezier = "enter" },
        { leaf = "layers",     enabled = true, speed = 2, bezier = "enter" },
        { leaf = "layersIn",   enabled = true, speed = 2, bezier = "enter",
           style = "popin 94%" },
        { leaf = "layersOut",  enabled = true, speed = 1, bezier = "exit",
           style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 2, bezier = "enter",
           style = "slidefade 15%" },
        { leaf = "zoomFactor", enabled = true, speed = 2, bezier = "enter" },
    },
}
""")

# ── alacritty ───────────────────────────────────────────────────────────
ALACRITTY = Template("""# $name — Alacritty
# $blurb

[colors.primary]
background = "$bg"
foreground = "$fg"
dim_foreground = "$fg1"

[colors.cursor]
text = "$bg"
cursor = "$accent"

[colors.selection]
text = "$fg"
background = "$bg3"

[colors.normal]
black   = "$bg2"
red     = "$red"
green   = "$green"
yellow  = "$yellow"
blue    = "$blue"
magenta = "$magenta"
cyan    = "$cyan"
white   = "$fg1"

[colors.bright]
black   = "$bg3"
red     = "$red"
green   = "$green"
yellow  = "$yellow"
blue    = "$blue"
magenta = "$magenta"
cyan    = "$cyan"
white   = "$fg"

[window]
padding = { x = 16, y = 14 }
decorations = "None"
opacity = $term_opacity
blur = true
dynamic_padding = true

[font]
normal = { family = "Adwaita Mono", style = "Regular" }
size = 13.0

[cursor]
style = { shape = "Beam", blinking = "On" }
blink_interval = 620
unfocused_hollow = true
""")

# ── neovim ──────────────────────────────────────────────────────────────
NVIM = Template("""-- $name — Neovim
-- $blurb
return {
  palette = {
    name = "$name",
    bg        = "$bg",
    bg1       = "$bg1",
    bg2       = "$bg2",
    bg3       = "$bg3",
    fg        = "$fg",
    fg1       = "$fg1",
    dim       = "$dim",
    sel       = "$bg3",
    accent    = "$accent",
    accent2   = "$accent2",
    red       = "$red",
    green     = "$green",
    blue      = "$blue",
    purple    = "$magenta",
    cyan      = "$cyan",
    orange           = "$accent",
    yellow           = "$yellow",
    transparent      = false,
    light            = $light_lua,
    italic_comments  = true,
    border           = "$bg3",
  },
  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "rounded",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
""")

# ── fastfetch ───────────────────────────────────────────────────────────
FASTFETCH = Template("""{
  "$$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "small",
    "padding": { "top": 1, "left": 2, "right": 4 },
    "color": { "1": "$ansi_accent", "2": "$ansi_accent2" }
  },
  "display": {
    "separator": "  ",
    "key": { "width": 9 },
    "color": { "title": "$ansi_accent" }
  },
  "modules": [
    "break",
    { "type": "title", "color": { "user": "$ansi_accent", "host": "$ansi_accent2" } },
    { "type": "custom", "format": "$rule" },
    { "type": "os",     "key": "os",   "keyColor": "$ansi_dim" },
    { "type": "kernel", "key": "kern", "keyColor": "$ansi_dim" },
    { "type": "wm",     "key": "wm",   "keyColor": "$ansi_dim" },
    { "type": "shell",  "key": "sh",   "keyColor": "$ansi_dim" },
    { "type": "terminal", "key": "term", "keyColor": "$ansi_dim" },
    { "type": "memory", "key": "mem",  "keyColor": "$ansi_dim" },
    { "type": "uptime", "key": "up",   "keyColor": "$ansi_dim" },
    { "type": "custom", "format": "$rule" },
    { "type": "custom", "format": "  $name \\u00b7 $blurb_short" },
    "break"
  ]
}
""")

# ── hyprlock ────────────────────────────────────────────────────────────
HYPRLOCK = Template("""# $name — hyprlock
# $blurb
#
# The wallpaper stays legible under the blur rather than being dimmed to a
# backdrop: this set is built around surfaces sitting on a visible desktop, and
# the lock screen is the last place to abandon that.

background {
    monitor =
    path = $wallpaper_path
    blur_passes = 3
    blur_size = 8
    brightness = $lock_brightness
    contrast = 1.0
    vibrancy = 0.18
}

input-field {
    monitor =
    size = 340, 52
    outline_thickness = 2
    dots_size = 0.24
    dots_spacing = 0.4
    dots_center = true
    outer_color = rgba($accent_hex)
    inner_color = rgba($bg1_hex_a)
    font_color = rgba($fg_hex)
    check_color = rgba($accent2_hex)
    fail_color = rgba($red_hex)
    fade_on_empty = false
    placeholder_text = <span foreground="##$faint_bare">Password</span>
    fail_text = <span foreground="##$red_bare">Wrong</span>
    rounding = 16
    position = 0, -60
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] date +"%H:%M"
    color = rgba($fg_hex)
    font_size = 84
    font_family = Adwaita Sans Light
    position = 0, 190
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:60000] date +"%A, %d %B"
    color = rgba($dim_hex)
    font_size = 16
    font_family = Adwaita Sans
    position = 0, 108
    halign = center
    valign = center
}

label {
    monitor =
    text = $name
    color = rgba($faint_hex)
    font_size = 11
    font_family = Adwaita Sans
    position = 0, 40
    halign = center
    valign = bottom
}
""")

WALLPAPER = Template("""# Bare path = applied to every monitor.
$wallpaper_path
transition=simple
""")

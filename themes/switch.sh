#!/usr/bin/env bash
# ~/.config/themes/switch.sh — swap the active rice.
#
# Every themed app reads its styling through the `current` symlink:
#
#   ~/.config/waybar/config.jsonc     -> themes/current/waybar.jsonc  (symlink)
#   ~/.config/waybar/style.css        -> themes/current/waybar.css    (symlink)
#   ~/.config/mako/config             -> themes/current/mako.conf     (symlink)
#   ~/.config/fastfetch/config.jsonc  -> themes/current/fastfetch.jsonc (symlink)
#   ~/.config/rofi/config.rasi        -> @import themes/current/rofi.rasi
#   ~/.config/alacritty/*.toml        -> import  themes/current/alacritty.toml
#   ~/.config/hypr/hyprland.lua       -> dofile  themes/current/hypr.lua
#   ~/.config/nvim/...                -> dofile  themes/current/nvim.lua
#
# So switching is: repoint one symlink, then poke each app to reload.
# Because the live paths are symlinks into the theme dir, editing
# ~/.config/waybar/style.css edits the *theme* — no copy to keep in sync.
#
# Usage:  switch.sh <profile>   |   switch.sh --next   |   switch.sh --current

set -euo pipefail

THEMES="$HOME/.config/themes"
LIST="$THEMES/profiles.list"
CURRENT="$THEMES/current"

profiles() { grep -vE '^\s*(#|$)' "$LIST" | cut -d'|' -f1; }

current_name() {
    [ -L "$CURRENT" ] && basename "$(readlink "$CURRENT")" || echo ""
}

usage() {
    echo "usage: switch.sh <profile>|--next|--current" >&2
    echo "profiles: $(profiles | tr '\n' ' ')" >&2
    exit 2
}

[ $# -eq 1 ] || usage

case "$1" in
    --current) current_name; exit 0 ;;
    --next)
        mapfile -t P < <(profiles)
        cur="$(current_name)"
        target="${P[0]}"
        for i in "${!P[@]}"; do
            if [ "${P[$i]}" = "$cur" ]; then
                target="${P[$(( (i + 1) % ${#P[@]} ))]}"
                break
            fi
        done
        ;;
    -*) usage ;;
    *)  target="$1" ;;
esac

[ -d "$THEMES/$target" ] || { echo "switch.sh: no such profile: $target" >&2; exit 1; }

# Every profile must be complete, or we would half-apply a rice and leave
# the desktop in a mixed state that is confusing to back out of.
missing=()
for f in waybar.jsonc waybar.css mako.conf rofi.rasi hypr.lua alacritty.toml \
         nvim.lua fastfetch.jsonc wallpaper hyprlock.conf starship.toml \
         shell.components launcher; do
    [ -f "$THEMES/$target/$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "switch.sh: profile '$target' is incomplete, missing: ${missing[*]}" >&2
    exit 1
fi

# Repoint atomically — ln -sfn onto a temp name then mv, so a reader never
# observes a missing `current`.
ln -sfn "$THEMES/$target" "$CURRENT.tmp"
mv -Tf "$CURRENT.tmp" "$CURRENT"

# ── Reload each app ────────────────────────────────────────────────────
# Desktop shell: each rice declares its own components (waybar, conky,
# yambar, a dock, or nothing at all) in shell.components. shell.sh tears the
# previous rice's shell down and brings this one's up, so switching profiles
# changes what the desktop *is*, not just how it is painted.
#
# waybar is restarted rather than SIGUSR2'd: 0.15 segfaults in its reload
# path with this many custom modules (Glib::DispatchNotifier assertion).
"$THEMES/shell.sh" restart >/dev/null 2>&1 || true

# mako: makoctl reload re-reads ~/.config/mako/config (our symlink).
command -v makoctl >/dev/null && makoctl reload 2>/dev/null || true

# hyprland: re-runs hyprland.lua, which dofile()s the new hypr.lua.
command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1 || true

# alacritty: live_config_reload watches the main config. Touching it forces
# a reload that re-resolves the import through the new symlink target —
# repointing the symlink alone does not disturb the inode alacritty watches.
touch "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || true

# wallpaper: apply the rice's wallpaper to every connected monitor.
#
# Monitors are enumerated from hyprctl rather than hardcoded, so this keeps
# working when a display is plugged/unplugged or renamed. themes/<n>/wallpaper
# holds either a bare path (all monitors) or <output>=<path> lines (per
# monitor, which kib-custom uses).
#
# hyprpaper 0.8 applies `wallpaper` live with no preload step, so the swap is
# instant; hyprpaper.conf is rewritten too so the choice survives a reboot.
WALL="$THEMES/$target/wallpaper"
if [ -f "$WALL" ] && command -v hyprctl >/dev/null; then
    # `|| true` is load-bearing: under `set -euo pipefail` a grep that
    # legitimately matches nothing (kib-custom has only per-monitor lines and
    # no bare fallback) exits 1 and would kill the whole switch silently.
    fallback="$(grep -vE '^\s*(#|$)' "$WALL" | grep -v '=' | head -1 || true)"
    transition="$(sed -n 's|^transition=||p' "$WALL" | head -1 || true)"
    [ -n "$transition" ] || transition=fade
    conf="$HOME/.config/hypr/hyprpaper.conf"
    : > "$conf.tmp"
    while read -r mon; do
        [ -n "$mon" ] || continue
        path="$(grep -vE '^\s*(#|$)' "$WALL" | sed -n "s|^${mon}=||p" | head -1 || true)"
        [ -n "$path" ] || path="$fallback"
        [ -n "$path" ] && [ -f "$path" ] || continue
        # Prefer swww: it animates the change, and the transition is chosen
        # per rice (outrun wipes in a wave, oxocarbon just cuts). Fall back to
        # hyprpaper if the daemon is not up, so this never leaves a blank desktop.
        # The AUR "swww" package currently installs as `awww` (upstream rename),
        # so resolve whichever client is actually present rather than assuming.
        SWWW=""
        for cand in swww awww; do
            command -v "$cand" >/dev/null 2>&1 || continue
            pgrep -x "${cand}-daemon" >/dev/null 2>&1 && { SWWW="$cand"; break; }
        done
        if [ -n "$SWWW" ]; then
            "$SWWW" img "$path" --outputs "$mon" \
                 --transition-type "$transition" --transition-duration 1.1 \
                 --transition-fps 60 >/dev/null 2>&1 || true
        else
            hyprctl hyprpaper wallpaper "$mon,$path" >/dev/null 2>&1 || true
        fi
        printf 'wallpaper {\n    monitor = %s\n    path = %s\n    fit_mode = cover\n}\n\n' \
               "$mon" "$path" >> "$conf.tmp"
    done < <(
        # Parse the JSON properly: a naive grep for "name" also picks up the
        # nested activeWorkspace names ("1", "2"), which are not monitors.
        hyprctl monitors -j 2>/dev/null | python3 -c '
import sys, json
try:
    for m in json.load(sys.stdin):
        print(m["name"])
except Exception:
    pass
' || true)
    if [ -s "$conf.tmp" ]; then mv -f "$conf.tmp" "$conf"; else rm -f "$conf.tmp"; fi
fi

# hyprlock and starship read their config at launch, so a symlink is enough --
# no reload needed for either.
ln -sfn "$CURRENT/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf" 2>/dev/null || true
ln -sfn "$CURRENT/starship.toml" "$HOME/.config/starship.toml" 2>/dev/null || true

# rofi and fastfetch both read their config fresh on every launch, and both
# resolve through the `current` symlink — nothing to signal for either.
# nvim applies on next launch; running instances can use  :ThemeReload
# (defined in ~/.config/nvim/lua/plugins/colorscheme.lua).

echo "$target"

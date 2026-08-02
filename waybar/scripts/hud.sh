#!/usr/bin/env bash
# On-demand status HUD — the whole "bar" for rices that have no chrome.
#
# mono and eink deliberately run no panel: the screen is windows and
# wallpaper, nothing else. The information a bar would have shown is still
# needed occasionally, so it is summoned with SUPER+I and dismissed with any
# key. Rendered in the active rice's rofi theme, so it matches whatever is
# live.
#
# This is a readout, not a menu: -no-custom and every row is inert.

set -uo pipefail

THEMES="$HOME/.config/themes"

bat() {
    local d=/sys/class/power_supply
    for b in "$d"/BAT*; do
        [ -r "$b/capacity" ] || continue
        local cap st
        cap="$(cat "$b/capacity")"; st="$(cat "$b/status" 2>/dev/null)"
        printf 'battery    %s%%  %s\n' "$cap" "$(printf '%s' "$st" | tr 'A-Z' 'a-z')"
        return
    done
    printf 'battery    (none)\n'
}

netline() {
    local ip ssid
    ip="$(ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' | head -1)"
    ssid="$(iwgetid -r 2>/dev/null)"
    if [ -n "${ssid:-}" ]; then printf 'network    %s  ·  %s\n' "$ssid" "${ip:-no address}"
    elif [ -n "${ip:-}" ];  then printf 'network    wired  ·  %s\n' "$ip"
    else printf 'network    offline\n'; fi
}

volline() {
    local v
    v="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%d", $2*100}')"
    local m=""
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && m="  (muted)"
    printf 'volume     %s%%%s\n' "${v:-?}" "$m"
}

rice="$(basename "$(readlink "$THEMES/current" 2>/dev/null)" 2>/dev/null)"
ws="$(hyprctl activeworkspace -j 2>/dev/null \
      | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])' 2>/dev/null)"

{
  date '+%A %d %B'
  date '+%H:%M'
  printf '\n'
  printf 'workspace  %s\n' "${ws:-?}"
  printf 'rice       %s\n' "${rice:-?}"
  netline
  volline
  bat
  printf 'uptime     %s\n' "$(uptime -p 2>/dev/null | sed 's/^up //')"
  printf 'memory     %s\n' "$(free -h --si | awk '/^Mem:/{print $3" / "$2}')"
  printf 'disk       %s\n' "$(df -h --output=used,size / | tail -1 | awk '{print $1" / "$2}')"
} | rofi -dmenu -i -p "status" -no-custom \
         -theme "$THEMES/picker.rasi" >/dev/null 2>&1 || true

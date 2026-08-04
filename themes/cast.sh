#!/usr/bin/env bash
# ~/.config/themes/cast.sh — cast this screen to a TV, Chromecast or Miracast
# display. Bound to SUPER+SHIFT+C.
#
# Rice-agnostic on purpose. Like picker.sh it renders in the *active* rice's
# rofi theme, so one script serves all profiles and no per-rice config has to
# know casting exists.
#
# There is no clean CLI on Wayland that mirrors a screen to a Chromecast, so
# this does the parts that can be automated -- discovery, preflight, launching
# and tearing down a backend -- and hands off to the one tool that actually
# speaks the protocol.
#
# Usage:
#   cast.sh                  the picker (default)
#   cast.sh discover         list devices found on the network
#   cast.sh start <name>     start casting to a device
#   cast.sh stop             stop casting
#   cast.sh status           print the active target, or nothing
#   cast.sh check            preflight: what is missing and how to fix it

set -uo pipefail

THEMES="$HOME/.config/themes"
CURRENT="$THEMES/current"
STATE="${XDG_RUNTIME_DIR:-/tmp}/cast.target"

# The GUI that speaks both Chromecast and Miracast. Everything else here is
# discovery and glue.
BACKEND="gnome-network-displays"

note() { command -v notify-send >/dev/null && notify-send -a cast "$@" || echo "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# ── preflight ─────────────────────────────────────────────────────────────
# Each of these fails in a way that looks like "casting is broken" but has a
# completely different fix, so they are reported separately.
check() {
    local ok=0

    if have avahi-browse; then
        if systemctl is-active --quiet avahi-daemon; then
            echo "ok      mDNS discovery (avahi-daemon running)"
        else
            echo "BROKEN  avahi-daemon is not running — no device will ever be found"
            echo "        fix: sudo systemctl enable --now avahi-daemon"
            ok=1
        fi
    else
        echo "BROKEN  avahi-browse missing — cannot discover devices"
        echo "        fix: sudo pacman -S avahi"
        ok=1
    fi

    # Without the ScreenCast portal nothing can capture the screen at all,
    # cast or otherwise.
    if busctl --user introspect org.freedesktop.portal.Desktop \
         /org/freedesktop/portal/desktop 2>/dev/null | grep -q ScreenCast; then
        echo "ok      ScreenCast portal is live"
    else
        echo "BROKEN  no ScreenCast portal — screen capture cannot start"
        echo "        fix: sudo pacman -S xdg-desktop-portal-hyprland"
        ok=1
    fi

    if have "$BACKEND"; then
        echo "ok      $BACKEND installed"
    else
        echo "MISSING $BACKEND — needed to mirror the screen to a device"
        echo "        fix: yay -S $BACKEND"
        ok=1
    fi

    have catt && echo "ok      catt installed (cast a file or URL without mirroring)"
    return $ok
}

# ── discovery ─────────────────────────────────────────────────────────────
# One "name<TAB>kind" line per device. Chromecast and AirPlay both announce
# over mDNS; Miracast does not, so those are found by the backend itself.
discover() {
    have avahi-browse || return 0
    systemctl is-active --quiet avahi-daemon || return 0

    timeout 6 avahi-browse -artp 2>/dev/null \
    | awk -F';' '
        $1 == "=" && $5 ~ /_googlecast|_airplay|_raop/ {
            name = $4
            gsub(/\\032/, " ", name)          # avahi escapes spaces
            gsub(/\\./, ".", name)
            kind = ($5 ~ /_googlecast/) ? "Chromecast" : "AirPlay"
            if (!(name in seen)) { seen[name] = 1; print name "\t" kind }
        }'
}

status() { [ -f "$STATE" ] && cat "$STATE"; }

is_casting() { pgrep -x "$BACKEND" >/dev/null 2>&1; }

# ── actions ───────────────────────────────────────────────────────────────
start() {
    local target="${1:-}"
    if ! have "$BACKEND"; then
        note "Casting unavailable" "$BACKEND is not installed. Run: yay -S $BACKEND"
        return 1
    fi
    printf '%s' "$target" > "$STATE"
    note "Casting" "${target:-Choose a device in the window that opens}"
    # The backend owns the session; it presents its own device list and drives
    # the ScreenCast portal itself.
    setsid "$BACKEND" >/dev/null 2>&1 </dev/null &
}

stop() {
    pkill -x "$BACKEND" 2>/dev/null
    rm -f "$STATE"
    note "Casting stopped"
}

# ── picker ────────────────────────────────────────────────────────────────
menu() {
    local rows="" devices n=0
    devices="$(discover)"

    if [ -n "$devices" ]; then
        while IFS=$'\t' read -r name kind; do
            [ -n "$name" ] || continue
            rows+="  ${name}  ·  ${kind}"$'\n'
            n=$((n + 1))
        done <<< "$devices"
    fi

    if is_casting; then
        rows+="  Stop casting"$'\n'
    fi
    rows+="  Open cast panel"$'\n'
    have google-chrome-stable || flatpak list 2>/dev/null | grep -qi chrome && \
        rows+="  Cast a tab with Chrome"$'\n'
    rows+="  Check setup"$'\n'

    local prompt="cast"
    [ "$n" -eq 0 ] && prompt="cast (no devices found)"

    local sel
    sel="$(printf '%s' "$rows" | rofi -dmenu -i -p "$prompt" \
            -theme "$THEMES/picker.rasi" \
            -theme-str "listview { lines: $(( $(printf '%s' "$rows" | grep -c .) )); columns: 1; }" \
            -no-custom 2>/dev/null || true)"
    [ -n "$sel" ] || exit 0

    sel="${sel#"${sel%%[![:space:]]*}"}"      # trim leading spaces

    case "$sel" in
        "Stop casting")          stop ;;
        "Open cast panel")       start "" ;;
        "Cast a tab with Chrome")
            # Chrome speaks Cast natively; this just opens it at the right place.
            if have google-chrome-stable; then
                setsid google-chrome-stable >/dev/null 2>&1 </dev/null &
            else
                setsid flatpak run com.google.Chrome >/dev/null 2>&1 </dev/null &
            fi
            note "Chrome" "Menu ⋮ → Cast… → Sources → Cast desktop" ;;
        "Check setup")
            check | rofi -dmenu -i -p "cast setup" -theme "$THEMES/picker.rasi" \
                    -theme-str 'listview { lines: 10; columns: 1; }' >/dev/null 2>&1 || true ;;
        *)  start "${sel%%  ·*}" ;;
    esac
}

case "${1:-menu}" in
    menu)     menu ;;
    discover) discover ;;
    status)   status ;;
    check)    check ;;
    start)    shift; start "${1:-}" ;;
    stop)     stop ;;
    *)        echo "usage: cast.sh [menu|discover|start <name>|stop|status|check]" >&2; exit 2 ;;
esac

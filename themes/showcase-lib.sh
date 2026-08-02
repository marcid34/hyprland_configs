#!/usr/bin/env bash
# Shared engine for the per-rice Documents/configmenu/<rice>/linux_showcase.sh
# scripts. Each of those is a thin manifest -- RICE, WORKSPACE and a WIDGETS
# array -- and calls showcase_main.
#
# Kept in one place rather than copied twenty times so a fix lands everywhere.

# Every package the showcases can use, mapped to its source. Split because
# AUR needs yay and the repo ones do not, and mixing them into one command
# means a single missing AUR package fails the whole install.
SHOWCASE_REPO_PKGS="cava btop fastfetch cmatrix asciiquarium yazi hypridle grim slurp swappy zoxide fzf starship zathura zathura-pdf-mupdf impala lolcat figlet"
# NB: the AUR "swww" package currently installs binaries named awww/
# awww-daemon (upstream rename), which is why switch.sh probes for both.
SHOWCASE_AUR_PKGS="wlogout swww tty-clock pipes.sh cbonsai"

showcase_theme_dir() { echo "$HOME/.config/themes/$RICE"; }

showcase_have() { command -v "$1" >/dev/null 2>&1; }

showcase_check() {
    local missing=() have=()
    for w in "${WIDGETS[@]}"; do
        local bin="${w%%|*}"
        if showcase_have "$bin"; then have+=("$bin"); else missing+=("$bin"); fi
    done
    printf '%s — widgets\n' "$RICE"
    printf '  installed: %s\n' "${have[*]:-none}"
    if [ ${#missing[@]} -gt 0 ]; then
        printf '  missing:   %s\n' "${missing[*]}"
        printf '\n  install with:\n    sudo pacman -S --needed %s\n' "${missing[*]}"
    fi
    printf '\n  full toolkit for every rice:\n'
    printf '    sudo pacman -S --needed %s\n' "$SHOWCASE_REPO_PKGS"
    printf '    yay -S --needed %s\n' "$SHOWCASE_AUR_PKGS"
}

# btop reads themes from ~/.config/btop/themes and is told which to use via
# its own config, so drop this rice's theme in and point btop at it.
showcase_btop_theme() {
    local src; src="$(showcase_theme_dir)/btop.theme"
    [ -r "$src" ] || return 0
    mkdir -p "$HOME/.config/btop/themes"
    cp -f "$src" "$HOME/.config/btop/themes/$RICE.theme"
    local cfg="$HOME/.config/btop/btop.conf"
    mkdir -p "$(dirname "$cfg")"
    touch "$cfg"
    if grep -q '^color_theme' "$cfg" 2>/dev/null; then
        sed -i "s|^color_theme.*|color_theme = \"$RICE\"|" "$cfg"
    else
        printf 'color_theme = "%s"\ntheme_background = %s\n' \
            "$RICE" "$( [ "$RICE" = dawn ] || [ "$RICE" = eink ] && echo False || echo True )" >> "$cfg"
    fi
}

showcase_close() {
    # Close by PID, not by Hyprland dispatch.
    #
    # `hyprctl dispatch closewindow address:0x...` is a no-op on 0.56 -- the
    # string dispatchers moved to the Lua engine (the same breakage that forced
    # scripts/hypr-ws.py to exist), and it errors with "dispatch in lua is a
    # shorthand for hl.dispatch(...)". The Lua side is no better here:
    # HL.Window carries fields but no close method, and hl.get_window() does
    # not accept a bare address. The client list already reports each window's
    # pid, so killing that is both simpler and independent of the compositor's
    # dispatch API entirely.
    local pids
    pids="$(hyprctl -j clients 2>/dev/null | python3 -c '
import sys, json
try: cs = json.load(sys.stdin)
except Exception: sys.exit(0)
for c in cs:
    if c.get("class", "").startswith("showcase-") and c.get("pid", 0) > 0:
        print(c["pid"])
')"
    if [ -z "$pids" ]; then
        echo "no showcase windows open"
        return 0
    fi
    local n=0
    for p in $pids; do kill "$p" 2>/dev/null && n=$((n + 1)); done
    echo "closed $n showcase window(s)"
}

showcase_main() {
    local here=0
    case "${1:-}" in
        --check) showcase_check; return 0 ;;
        --close) showcase_close; return 0 ;;
        --here)  here=1 ;;
        "")      ;;
        *)       echo "usage: linux_showcase.sh [--here|--check|--close]" >&2; return 2 ;;
    esac

    command -v hyprctl >/dev/null || { echo "hyprland not running" >&2; return 1; }

    # Switch rice first so the widgets inherit its terminal colours.
    if [ -x "$HOME/.config/themes/switch.sh" ]; then
        "$HOME/.config/themes/switch.sh" "$RICE" >/dev/null || true
        sleep 1.2
    fi
    showcase_btop_theme

    # Put the showcase on the external display when one is attached -- it is
    # the bigger panel and the point of a showcase is to be looked at.
    # Internal panels are eDP/LVDS/DSI; anything else is external.
    if [ "$here" != 1 ]; then
        local mon
        mon="$(hyprctl monitors -j 2>/dev/null | python3 -c '
import sys, json
try: ms = json.load(sys.stdin)
except Exception: sys.exit(0)
ext = [m["name"] for m in ms if not m["name"].startswith(("eDP","LVDS","DSI"))]
print(ext[0] if ext else (ms[0]["name"] if ms else ""))
')"
        # `hyprctl dispatch workspace N` is a no-op on 0.56 and errors with
        # "')' expected near '9'" -- dispatch moved to the Lua engine. Same
        # reason scripts/hypr-ws.py speaks repl.
        #
        # Order matters: focus the monitor *first*. A workspace that does not
        # exist yet cannot be moved, so calling workspace.move before it exists
        # is a silent no-op and the subsequent focus creates it on whichever
        # monitor happened to be focused -- the laptop panel. Focusing the
        # monitor first means the workspace is created in the right place; the
        # move afterwards only matters when it already existed elsewhere.
        if [ -n "$mon" ]; then
            hyprctl repl "hl.dispatch(hl.dsp.focus({monitor = '$mon'}))" >/dev/null 2>&1 || true
            sleep 0.2
            hyprctl repl "hl.dispatch(hl.dsp.focus({workspace = $WORKSPACE}))" >/dev/null 2>&1 || true
            sleep 0.2
            hyprctl repl "hl.dispatch(hl.dsp.workspace.move({workspace = $WORKSPACE, monitor = '$mon'}))" >/dev/null 2>&1 || true
        else
            hyprctl repl "hl.dispatch(hl.dsp.focus({workspace = $WORKSPACE}))" >/dev/null 2>&1 || true
        fi
        SHOWCASE_MON="${mon:-?}"
    fi
    sleep 0.4

    local THEME_DIR launched=0 skipped=()
    THEME_DIR="$(showcase_theme_dir)"
    export THEME_DIR

    for w in "${WIDGETS[@]}"; do
        local bin="${w%%|*}" cmd="${w#*|}"
        if ! showcase_have "$bin"; then skipped+=("$bin"); continue; fi
        # Plain substitution, deliberately not eval: the commands contain `;`
        # and `$SHELL`, and `eval echo "$cmd"` would split on the semicolon and
        # run the second half in *this* shell -- `exec $SHELL` among them.
        local run="${cmd//\$THEME_DIR/$THEME_DIR}"
        setsid alacritty --class "showcase-$bin" \
               -e bash -lc "$run" >/dev/null 2>&1 &
        launched=$((launched + 1))
        sleep 0.45   # let hyprland place each one before the next arrives
    done

    if [ "$here" = 1 ]; then
        echo "$RICE showcase: $launched widget(s) on the current workspace"
    else
        echo "$RICE showcase: $launched widget(s) on workspace $WORKSPACE (${SHOWCASE_MON:-?})"
    fi
    if [ ${#skipped[@]} -gt 0 ]; then
        echo "  not installed: ${skipped[*]}"
        echo "  sudo pacman -S --needed ${skipped[*]}"
    fi
    echo "  close them with: $0 --close"
}

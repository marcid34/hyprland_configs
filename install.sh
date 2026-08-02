#!/usr/bin/env bash
# install.sh — set up the whole desktop, or just the parts you name.
#
#   ./install.sh                    everything, prompting before each replacement
#   ./install.sh -y                 everything, no prompts
#   ./install.sh hypr waybar        only those components
#   ./install.sh -n                 dry run — show what would change
#   ./install.sh --list             show components and exit
#
# Each component is also runnable on its own (./hypr/install.sh); this script
# only adds ordering and a summary.

set -euo pipefail
HC_COMPONENT=hyprland_configs
source "$(dirname "$(readlink -f "$0")")/lib/common.sh"

# themes MUST be first: it creates ~/.config/themes/current, which every
# other component links its styling through. The rest are independent.
ORDER=(themes hypr waybar mako rofi alacritty fastfetch
       nwg-dock-hyprland nwg-drawer nwg-panel
       cava btop nvim fontconfig)

want=()
opts=()
for arg in "$@"; do
    case "$arg" in
        --list) printf '%s\n' "${ORDER[@]}"; exit 0 ;;
        -*)     opts+=("$arg") ;;
        *)      want+=("$arg") ;;
    esac
done

# Parse only the flags, so --help/--dry-run behave before any work starts.
hc_init "${opts[@]+"${opts[@]}"}"

if [ ${#want[@]} -gt 0 ]; then
    for c in "${want[@]}"; do
        [ -x "$HC_REPO/$c/install.sh" ] || hc_die "no such component: $c (try --list)"
    done
    run=("${want[@]}")
    # Preserve dependency order even when components are named out of order.
    if printf '%s\n' "${run[@]}" | grep -qx themes; then
        run=(themes $(printf '%s\n' "${run[@]}" | grep -vx themes || true))
    fi
else
    run=("${ORDER[@]}")
fi

hc_log "installing: ${run[*]}"
echo

failed=()
for c in "${run[@]}"; do
    printf '%s┌─ %s %s%s\n' "$HC_C_BLU" "$c" "$(printf '─%.0s' $(seq 1 $((60 - ${#c}))))" "$HC_C_RST"
    if "$HC_REPO/$c/install.sh" "${opts[@]+"${opts[@]}"}"; then :; else
        hc_err "$c failed"
        failed+=("$c")
    fi
done

printf '%s%s%s\n' "$HC_C_BLU" "$(printf '─%.0s' $(seq 1 64))" "$HC_C_RST"
if [ ${#failed[@]} -gt 0 ]; then
    hc_err "failed: ${failed[*]}"
    exit 1
fi

hc_ok "all components installed"
cat <<'EOF'

  Next:
    themes/switch.sh --next        cycle to the next rice
    themes/switch.sh dracula       apply one by name
    themes/switch.sh --current     which one is active

  Wallpapers are not in this repo — drop images at
  ~/Pictures/Wallpapers/themes/<rice>.{jpg,png} to fill them in.

  Log out and back into Hyprland to pick up the compositor config.
EOF

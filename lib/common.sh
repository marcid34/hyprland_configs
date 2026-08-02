#!/usr/bin/env bash
# lib/common.sh — shared machinery for every per-folder install.sh.
#
# Each folder's installer is meant to stay declarative: it says which packages
# it needs and which paths it owns, and everything procedural lives here.
#
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
#   hc_deps  hyprland hypridle
#   hc_link  hypr
#   hc_done
#
# Sourced, never executed directly.

set -euo pipefail

# ── Repo location ──────────────────────────────────────────────────────
# Resolved from this file rather than $PWD, so the installers work when
# invoked from anywhere ( ./hypr/install.sh  and  cd hypr && ./install.sh ).
HC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HC_REPO="$(cd "$HC_LIB_DIR/.." && pwd)"
HC_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# The home directory the configs in this repo were authored against. Paths
# baked into config files are rewritten from this to the current $HOME by
# hc_hydrate. Keep in sync with whatever `git grep -l /home/` reports.
HC_ORIGIN_HOME="/home/kib"

# ── Options (parsed by hc_init, settable from the environment) ─────────
HC_YES="${HC_YES:-0}"        # --yes       assume yes, never prompt
HC_NO_DEPS="${HC_NO_DEPS:-0}" # --no-deps  skip package checks entirely
HC_DRY="${HC_DRY:-0}"        # --dry-run   print actions, change nothing

HC_STAMP="$(date +%Y%m%d-%H%M%S)"
HC_MISSING_PKGS=()
HC_COMPONENT="${HC_COMPONENT:-$(basename "$PWD")}"

# ── Output ─────────────────────────────────────────────────────────────
if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
    HC_C_DIM=$'\033[2m'; HC_C_RED=$'\033[31m'; HC_C_GRN=$'\033[32m'
    HC_C_YLW=$'\033[33m'; HC_C_BLU=$'\033[34m'; HC_C_RST=$'\033[0m'
else
    HC_C_DIM=; HC_C_RED=; HC_C_GRN=; HC_C_YLW=; HC_C_BLU=; HC_C_RST=
fi

hc_log()  { printf '%s==>%s %s\n' "$HC_C_BLU" "$HC_C_RST" "$*"; }
hc_info() { printf '    %s\n' "$*"; }
hc_dim()  { printf '    %s%s%s\n' "$HC_C_DIM" "$*" "$HC_C_RST"; }
hc_warn() { printf '%s !! %s%s\n' "$HC_C_YLW" "$*" "$HC_C_RST" >&2; }
hc_err()  { printf '%sERROR:%s %s\n' "$HC_C_RED" "$HC_C_RST" "$*" >&2; }
hc_ok()   { printf '%s  ✓ %s%s\n' "$HC_C_GRN" "$*" "$HC_C_RST"; }
hc_die()  { hc_err "$*"; exit 1; }

# Yes/no prompt. Returns 0 for yes. Under --yes it answers itself; with no
# tty (piped into bash, run from a hook) it declines rather than hanging.
hc_confirm() {
    local prompt="$1"
    [ "$HC_YES" = "1" ] && { hc_dim "$prompt [auto-yes]"; return 0; }
    [ -t 0 ] || { hc_dim "$prompt [no tty, assuming no]"; return 1; }
    local reply
    read -r -p "    $prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy] ]]
}

# Run a command, honouring --dry-run.
hc_run() {
    if [ "$HC_DRY" = "1" ]; then hc_dim "would run: $*"; return 0; fi
    "$@"
}

hc_init() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -y|--yes)     HC_YES=1 ;;
            --no-deps)    HC_NO_DEPS=1 ;;
            -n|--dry-run) HC_DRY=1 ;;
            -h|--help)    hc_usage; exit 0 ;;
            *) hc_die "unknown option: $1 (try --help)" ;;
        esac
        shift
    done
    export HC_YES HC_NO_DEPS HC_DRY
    [ "$HC_DRY" = "1" ] && hc_warn "dry run — nothing will be modified"
    return 0
}

hc_usage() {
    cat <<EOF
usage: $(basename "${BASH_SOURCE[1]:-install.sh}") [options]

  -y, --yes       don't prompt; install missing packages and overwrite
      --no-deps   skip the package check entirely
  -n, --dry-run   report what would happen, change nothing
  -h, --help      this message
EOF
}

# ── Packages ───────────────────────────────────────────────────────────
# Arguments are  <pkg>  or  <command>:<pkg>  when they differ
# (e.g. "python3:python", "makoctl:mako").
hc_aur_helper() {
    for h in yay paru; do command -v "$h" >/dev/null 2>&1 && { echo "$h"; return; }; done
    echo ""
}

hc_deps() {
    [ "$HC_NO_DEPS" = "1" ] && return 0
    [ $# -eq 0 ] && return 0

    local missing=() spec cmd pkg
    for spec in "$@"; do
        cmd="${spec%%:*}"; pkg="${spec##*:}"
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$pkg")
    done

    hc_log "checking deps: $*"
    if [ ${#missing[@]} -eq 0 ]; then hc_dim "all present"; return 0; fi

    hc_warn "missing: ${missing[*]}"
    HC_MISSING_PKGS+=("${missing[@]}")

    if ! command -v pacman >/dev/null 2>&1; then
        hc_info "not an Arch system — install these with your package manager, then re-run"
        return 0
    fi

    local helper; helper="$(hc_aur_helper)"
    local installer=("sudo" "pacman" "-S" "--needed")
    [ -n "$helper" ] && installer=("$helper" "-S" "--needed")

    if hc_confirm "install with ${installer[0]}?"; then
        hc_run "${installer[@]}" "${missing[@]}" || hc_warn "package install failed — continuing, configs will still be linked"
    else
        hc_info "skipped; ${missing[*]} still needed for this component to work"
    fi
    return 0
}

# ── Backup + link ──────────────────────────────────────────────────────
# Move an existing path aside. Symlinks that already point where we want are
# left alone by hc_link before this is ever called.
hc_backup() {
    local target="$1"
    [ -e "$target" ] || [ -L "$target" ] || return 0
    local dest="$target.bak.$HC_STAMP"
    hc_info "backing up $(hc_tilde "$target") → $(hc_tilde "$dest")"
    hc_run mv -T "$target" "$dest"
}

hc_tilde() { printf '%s' "${1/#$HOME/\~}"; }

# hc_link <name> [dest]
# Symlinks $HC_REPO/<name> to ~/.config/<name> (or an explicit dest).
hc_link() {
    local name="$1"
    local src="$HC_REPO/$name"
    local dst="${2:-$HC_CONFIG/$name}"

    [ -e "$src" ] || hc_die "missing in repo: $src"

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        hc_ok "$(hc_tilde "$dst") already linked"
        return 0
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ "$HC_YES" != "1" ] && ! hc_confirm "$(hc_tilde "$dst") exists — back it up and replace?"; then
            hc_warn "left $(hc_tilde "$dst") untouched"
            return 0
        fi
        hc_backup "$dst"
    fi

    hc_run mkdir -p "$(dirname "$dst")"
    hc_run ln -sfn "$src" "$dst"
    hc_ok "$(hc_tilde "$dst") → $(hc_tilde "$src")"
}

# hc_link_file <repo-relative-file> <dest>  — for single files rather than dirs.
hc_link_file() { hc_link "$1" "$2"; }

# ── Path hydration ─────────────────────────────────────────────────────
# A few configs cannot express "my home directory" portably and must carry an
# absolute path:
#
#   alacritty/alacritty.toml      working_directory — alacritty expands
#                                 neither ~ nor $HOME (verified, 0.17)
#   themes/*/hyprlock.conf        background image path
#   themes/*/wallpaper            per-rice wallpaper paths
#
# On the machine these configs were authored on this is a no-op. Anywhere
# else it rewrites the repo working tree once, which shows up as a normal
# `git diff` — see README "Installing on a different machine".
hc_hydrate() {
    [ "$HOME" = "$HC_ORIGIN_HOME" ] && return 0

    local files
    mapfile -t files < <(grep -rIl --exclude-dir=.git -- "$HC_ORIGIN_HOME" "$HC_REPO" 2>/dev/null || true)
    [ ${#files[@]} -eq 0 ] && return 0

    hc_log "rewriting $HC_ORIGIN_HOME → $HOME in ${#files[@]} file(s)"
    for f in "${files[@]}"; do hc_dim "$(hc_tilde "$f")"; done
    hc_run sed -i "s|$HC_ORIGIN_HOME|$HOME|g" "${files[@]}"
    hc_info "these now show as local modifications in git — that is expected"
}

# ── Theme symlinks ─────────────────────────────────────────────────────
# switch.sh repoints these on every rice change, but they have to exist
# before the first switch or waybar/mako/hyprlock come up with no config.
#
# Each component wires only its own link, so installers never create
# directories another component owns (which would leave the second installer
# backing up a directory the first one just made).
#
#   hc_theme_link <file-in-rice> <destination>
hc_theme_link() {
    local file="$1" dst="$2"
    local cur="$HC_CONFIG/themes/current"

    if [ ! -L "$cur" ]; then
        hc_warn "themes/current is not set — run themes/install.sh, then re-run this"
        return 0
    fi
    if [ ! -e "$cur/$file" ]; then
        hc_dim "skip $file (not present in the active rice)"
        return 0
    fi

    hc_run mkdir -p "$(dirname "$dst")"
    hc_run ln -sfn "$cur/$file" "$dst"
    hc_ok "$(hc_tilde "$dst") → themes/current/$file"
}

hc_done() {
    if [ ${#HC_MISSING_PKGS[@]} -gt 0 ]; then
        hc_warn "still missing: ${HC_MISSING_PKGS[*]}"
    fi
    hc_ok "${HC_COMPONENT} installed"
    echo
}

# hyprland_configs

A Hyprland desktop with 33 interchangeable rices. Switching a rice swaps the
terminal, bar, launcher, notifications, lock screen, editor colours, prompt
and wallpaper together — and can change *what the desktop is*, not just how
it's painted: some profiles run waybar, some a dock, some conky, some nothing.

```
themes/switch.sh dracula      # apply one
themes/switch.sh --next       # cycle
themes/switch.sh --current    # what's active
Super + T                     # rofi theme picker
```

## Install

```bash
git clone https://github.com/marcid34/hyprland_configs.git
cd hyprland_configs
./install.sh
```

Each component installs on its own too:

```bash
./install.sh hypr waybar      # just these
./hypr/install.sh             # equivalently, directly
./install.sh --dry-run        # show what would change, touch nothing
./install.sh -y               # no prompts
./install.sh --list           # component names
```

The installer backs up anything it replaces to `<path>.bak.<timestamp>`,
then symlinks the repo directory into `~/.config`. Because it's a symlink,
editing `~/.config/waybar/style.css` edits this repo — there's no copy to
keep in sync. It's idempotent: re-running it on an already-installed system
reports "already linked" and moves on.

Missing packages are detected per component and offered to `yay`/`paru`, or
`pacman` if no AUR helper is present. `--no-deps` skips the check.

## How the rice system works

One symlink drives everything:

```
~/.config/themes/current  ->  ~/.config/themes/<rice>
```

Apps reach their styling through it, in one of two ways:

| Consumer | Mechanism |
| --- | --- |
| `waybar`, `mako`, `fastfetch`, `hyprlock`, `starship` | the live config path *is* a symlink into `themes/current/` |
| `rofi`, `alacritty`, `hypr`, `nvim` | the real config `@import`s / `dofile()`s out of `themes/current/` |

So a switch is: repoint one symlink, then poke each app to reload.
`themes/switch.sh` does that, and refuses to apply a rice that's missing any
of its thirteen required files rather than half-applying one.

A rice is a directory of thirteen files:

```
themes/<rice>/
  alacritty.toml  btop.theme   cava.conf    fastfetch.jsonc
  hypr.lua        hyprlock.conf  mako.conf  nvim.lua
  rofi.rasi       rofi-grid.rasi  starship.toml
  waybar.jsonc    waybar.css
  shell.components   which desktop components this rice runs
  wallpaper          image path(s) + transition
  launcher           which launcher layout to use
```

Copy an existing one, edit the colours, add it to `themes/profiles.list`.

## Layout

```
install.sh            orchestrator — ordering and summary only
lib/common.sh         all the shared machinery (deps, backup, link, rewrite)
<component>/install.sh  declarative: which packages, which paths
```

`themes/` installs first because it creates `current`, which everything else
links through. The rest are independent.

## What isn't tracked

**Wallpapers.** 48M of images, mostly not mine to redistribute. Each rice
expects `~/Pictures/Wallpapers/themes/<rice>.{jpg,png}`. `switch.sh` skips a
missing image and applies the rest of the rice, so nothing breaks — the
desktop just keeps the previous wallpaper.

**Generated state**, listed in `.gitignore`: the `themes/current` symlink,
the per-app theme symlinks, and `hypr/hyprpaper.conf` — which `switch.sh`
rewrites from `hyprctl monitors` on every change, so it reflects whatever
displays were plugged in at the time.

**nwg-panel's icon sets**, which ship with the package.

## Installing on a different machine

Three things are machine-specific.

**Monitors.** `hypr/hyprland.lua` pins `eDP-1` and `HDMI-A-2` to explicit
coordinates — deliberately, because `auto` ordering flips when the dGPU is
primary. On other hardware, edit those `hl.monitor{}` blocks or replace both
with `hl.monitor({ output = ',preferred,auto,1' })`.

**Absolute paths.** Three consumers can't express "my home directory"
portably, so they carry a real path: `alacritty`'s `working_directory`
(alacritty 0.17 expands neither `~` nor `$HOME` there — it silently falls
back to inheriting the parent's cwd), and the wallpaper paths in each rice's
`hyprlock.conf` and `wallpaper`. If `$HOME` isn't `/home/kib`, the installer
rewrites them once and tells you which files it touched. That shows up as a
normal `git diff` — commit it on your fork, or `git checkout` those paths
before sending a PR back.

`rofi`'s imports are relative rather than absolute, so they need no rewriting.

**Fonts.** The bars and terminal assume a Nerd Font is installed.

## Keybinds

`Super` is the modifier. Full list in `hypr/hyprland.lua`.

| | |
| --- | --- |
| `Super + Q` / `C` | terminal / close window |
| `Super + R` / `E` | launcher / file manager |
| `Super + T` | theme picker |
| `Super + L` | lock |
| `Super + I` | status HUD (works even on rices with no bar) |
| `Super + F` | fullscreen |
| `Super + Shift + S` | region screenshot → swappy |
| `Print` | full screenshot → file + clipboard |
| `Super + N` | dismiss notification (`Shift` toggles do-not-disturb) |
| `Super + 1..0` | workspace (`Shift` moves window there) |
| `Super + S` | special workspace |

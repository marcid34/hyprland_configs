# The "soft modern" set

The generator behind ten rices: `halcyon`, `vellum`, `cobalt`, `orchid`,
`seafoam`, `graphite`, `ember`, `glacier`, `nocturne`, `matcha`.

These ten are one design in ten colourings, not ten designs. They share a
Quickshell shell (three floating islands, a launcher, a dashboard), one motion
system, and one set of metrics. Only `Theme.qml` differs between them — which
means hand-editing them would guarantee they drift apart, so they are
generated instead.

## Regenerating

```
python3 docs/soft/gen.py
```

Writes `themes/<rice>/` for all ten: the twelve files `switch.sh` requires,
plus `quickshell/` with the shell and its components. Safe to re-run — it
overwrites its own output and touches nothing else.

After changing a palette, also refresh the swatches the rice menu reads:

```
python3 docs/gen_palette_index.py
```

## Layout

| File | Holds |
| --- | --- |
| `palettes.py` | the ten palettes, and the colour-format helpers |
| `qml.py` | `Theme`, `Surface`, `Chip`, `Workspaces`, `Ring`, `Slider` |
| `qml2.py` | `Launcher`, `Dash` |
| `qml3.py` | `shell.qml` — the bar, the sampling, the IPC surface |
| `conf.py` | everything not QML: waybar, mako, rofi, hypr, alacritty, nvim, fastfetch, hyprlock |
| `gen.py` | the driver, and the derived values each template needs |

Templates are `string.Template` (`$token`), not `str.format` — QML is mostly
braces. The consequence is that **no template may contain a bare `$`**, which
rules out JS template literals; use concatenation instead.

## Adding an eleventh

Append to `RICES` in `palettes.py`, then:

```
python3 docs/soft/gen.py
python3 docs/gen_palette_index.py
```

and add the name to `themes/profiles.list`, to the *Soft modern* group in
`docs/gen_readme.py` and `docs/gen_rices_html.py`, and to `docs/tags.json`.

## Wallpapers

`wall2.py` searches wallhaven by dominant colour and builds contact sheets;
`wall_final.py` downloads the chosen ids at full resolution. The choice in
`wall_final.CHOICE` was made by looking at the sheets — colour scoring only
narrowed the pool, because sorting by relevance on mood words returns stock
photography that matches the words and not the desktop.

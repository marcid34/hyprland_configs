-- emerald — Hyprland
-- Emerald — deep green glass. Jewel tones on near-black forest.
-- speed is a DURATION in ds (1ds = 100ms): higher is slower.

return {
    general = {
        gaps_in = 2, gaps_out = 6,
        border_size = 1,
        col = {
            active_border   = "rgba(2ee68aff)",
            inactive_border = "rgba(123024ff)",
        },
    },
    decoration = {
        rounding = 4, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 0.94,
        dim_inactive = true, dim_strength = 0.16,
        shadow = { enabled = true, range = 18,
                   render_power = 3, color = "rgba(00000099)" },
        blur = { enabled = true, size = 7,
                 passes = 3, vibrancy = 0.2, ignore_opacity = true },
    },
    curves = {
        { name = "ease", type = "bezier", points = { {0.25, 1}, {0.4, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "pop", type = "spring", mass = 1, stiffness = 320, dampening = 23 },
    },
    animations = {
        { leaf = "global",     enabled = true, speed = 2,   bezier = "ease" },
        { leaf = "border",     enabled = true, speed = 2,   bezier = "ease" },
        { leaf = "windows",    enabled = true, speed = 2,   spring = "pop" },
        { leaf = "windowsIn",  enabled = true, speed = 2,   spring = "pop",  style = "popin 90%" },
        { leaf = "windowsOut", enabled = true, speed = 1, bezier = "ease", style = "popin 92%" },
        { leaf = "fade",       enabled = true, speed = 1, bezier = "ease" },
        { leaf = "layers",     enabled = true, speed = 2,   bezier = "ease" },
        { leaf = "layersIn",   enabled = true, speed = 2,   bezier = "ease", style = "popin 94%" },
        { leaf = "layersOut",  enabled = true, speed = 1, bezier = "ease", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 2,   bezier = "ease", style = "slide" },
        { leaf = "zoomFactor", enabled = true, speed = 2,   bezier = "ease" },
    },
}

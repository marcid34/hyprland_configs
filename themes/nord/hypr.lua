-- nord — Hyprland
-- Nord — arctic. Cool blue-greys, frost cyan, zero warmth.
-- speed is a DURATION in ds (1ds = 100ms): higher is slower.

return {
    general = {
        gaps_in = 5, gaps_out = 10,
        border_size = 1,
        col = {
            active_border   = "rgba(88c0d0ff)",
            inactive_border = "rgba(3b4252ff)",
        },
    },
    decoration = {
        rounding = 0, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 1.0,
        dim_inactive = true, dim_strength = 0.16,
        shadow = { enabled = false, range = 0,
                   render_power = 3, color = "rgba(00000099)" },
        blur = { enabled = false, size = 1,
                 passes = 1, vibrancy = 0.2, ignore_opacity = true },
    },
    curves = {
        { name = "ease", type = "bezier", points = { {0.25, 1}, {0.4, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "pop", type = "spring", mass = 1, stiffness = 240, dampening = 23 },
    },
    animations = {
        { leaf = "global",     enabled = true, speed = 3,   bezier = "ease" },
        { leaf = "border",     enabled = true, speed = 3,   bezier = "ease" },
        { leaf = "windows",    enabled = true, speed = 3,   spring = "pop" },
        { leaf = "windowsIn",  enabled = true, speed = 3,   spring = "pop",  style = "popin 96%" },
        { leaf = "windowsOut", enabled = true, speed = 2, bezier = "ease", style = "popin 96%" },
        { leaf = "fade",       enabled = true, speed = 2, bezier = "ease" },
        { leaf = "layers",     enabled = true, speed = 3,   bezier = "ease" },
        { leaf = "layersIn",   enabled = true, speed = 3,   bezier = "ease", style = "popin 94%" },
        { leaf = "layersOut",  enabled = true, speed = 2, bezier = "ease", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 3,   bezier = "ease", style = "slidefade 12%" },
        { leaf = "zoomFactor", enabled = true, speed = 3,   bezier = "ease" },
    },
}

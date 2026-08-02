-- kanagawa — Hyprland
--
-- Brush-stroke motion: a slow start that accelerates and then stops cleanly,
-- like a stroke being drawn. Modest rounding and a flat carp-yellow border;
-- blur is light because this palette is warm and heavy blur muddies it.

return {
    general = {
        gaps_in  = 4,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border   = "rgba(e6c384ee)",
            inactive_border = "rgba(2a2a37ff)",
        },
    },

    decoration = {
        rounding       = 6,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        dim_inactive = false,
        shadow = {
            enabled      = true,
            range        = 14,
            render_power = 3,
            color        = "rgba(0d0d12dd)",
        },
        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.12,
        },
    },

    curves = {
        { name = "stroke", type = "bezier", points = { {0.6, 0.04}, {0.24, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "brush",  type = "spring", mass = 1, stiffness = 210, dampening = 24 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 4,   bezier = "stroke" },
        { leaf = "border",     enabled = true, speed = 3,   bezier = "stroke" },
        { leaf = "windows",    enabled = true, speed = 4,   spring = "brush" },
        { leaf = "windowsIn",  enabled = true, speed = 4,   bezier = "stroke", style = "slide" },
        { leaf = "windowsOut", enabled = true, speed = 3,   bezier = "stroke", style = "slide" },
        { leaf = "fade",       enabled = true, speed = 3.5,   bezier = "stroke" },
        { leaf = "layers",     enabled = true, speed = 3.5,   bezier = "stroke" },
        { leaf = "layersIn",   enabled = true, speed = 3.5,   bezier = "stroke", style = "slide" },
        { leaf = "layersOut",  enabled = true, speed = 3,   bezier = "stroke", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 4,   bezier = "stroke", style = "slide" },
        { leaf = "zoomFactor", enabled = true, speed = 3.5,   bezier = "stroke" },
    },
}

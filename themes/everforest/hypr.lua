-- everforest — Hyprland
--
-- Calm and slightly slow. Everything eases out with no overshoot; the point
-- of this palette is reduced stimulation, and bounce is stimulation. Light
-- blur keeps the muted greens from turning to sludge.

return {
    general = {
        gaps_in  = 5,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(a7c080dd)", "rgba(83c092dd)" }, angle = 20 },
            inactive_border = "rgba(343f44ff)",
        },
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.94,
        dim_inactive = true,
        dim_strength = 0.10,
        shadow = {
            enabled      = true,
            range        = 16,
            render_power = 3,
            color        = "rgba(1e2429cc)",
        },
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.15,
        },
    },

    curves = {
        { name = "calm",   type = "bezier", points = { {0.25, 0.9}, {0.35, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "rest",   type = "spring", mass = 1, stiffness = 160, dampening = 28 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 4.5,   bezier = "calm" },
        { leaf = "border",     enabled = true, speed = 3.5,   bezier = "calm" },
        { leaf = "windows",    enabled = true, speed = 4.5,   spring = "rest" },
        { leaf = "windowsIn",  enabled = true, speed = 4.5,   bezier = "calm", style = "popin 90%" },
        { leaf = "windowsOut", enabled = true, speed = 3.5,   bezier = "calm", style = "popin 92%" },
        { leaf = "fade",       enabled = true, speed = 4, bezier = "calm" },
        { leaf = "layers",     enabled = true, speed = 4,   bezier = "calm" },
        { leaf = "layersIn",   enabled = true, speed = 4,   bezier = "calm", style = "fade" },
        { leaf = "layersOut",  enabled = true, speed = 3.5,   bezier = "calm", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 4.5,   bezier = "calm", style = "slidefade 12%" },
        { leaf = "zoomFactor", enabled = true, speed = 4,   bezier = "calm" },
    },
}

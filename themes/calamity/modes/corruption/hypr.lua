-- calamity (corruption) — Hyprland
--
-- Shadow-purple void, cursed-flame green. The Corruption: vertical chasms, demonite, and a sky that never warms.
-- Borders run the biome's two signature colours. Motion is short and firm:
-- Terraria's UI snaps open, it does not drift.

return {
    general = {
        gaps_in  = 4,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(9d7cd8ee)", "rgba(7bd88fee)" }, angle = 45 },
            inactive_border = "rgba(3b2a60cc)",
        },
    },

    decoration = {
        rounding       = 4,
        rounding_power = 2.0,
        active_opacity   = 1.0,
        inactive_opacity = 0.94,
        dim_inactive = false,
        shadow = {
            enabled      = true,
            range        = 14,
            render_power = 3,
            color        = "rgba(191029dd)",
        },
        blur = {
            enabled        = true,
            size           = 6,
            passes         = 2,
            vibrancy       = 0.15,
            ignore_opacity = true,
            popups         = true,
        },
    },

    curves = {
        { name = "snap",   type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } },
        { name = "glide",  type = "bezier", points = { {0.25, 1}, {0.5, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "pop",    type = "spring", mass = 1, stiffness = 340, dampening = 24 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 4,   bezier = "snap" },
        { leaf = "border",     enabled = true, speed = 3,   bezier = "snap" },
        { leaf = "windows",    enabled = true, speed = 4,   spring = "pop" },
        { leaf = "windowsIn",  enabled = true, speed = 4,   spring = "pop",   style = "popin 85%" },
        { leaf = "windowsOut", enabled = true, speed = 3,   bezier = "snap",  style = "popin 88%" },
        { leaf = "fade",       enabled = true, speed = 3.5, bezier = "glide" },
        { leaf = "layers",     enabled = true, speed = 3.5, bezier = "snap" },
        { leaf = "layersIn",   enabled = true, speed = 3.5, bezier = "snap",  style = "popin 90%" },
        { leaf = "layersOut",  enabled = true, speed = 3,   bezier = "glide", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 4,   bezier = "snap",  style = "slidefade 12%" },
        { leaf = "zoomFactor", enabled = true, speed = 3,   bezier = "snap" },
    },
}

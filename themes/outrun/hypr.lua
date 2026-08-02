-- outrun — Hyprland
--
-- Neon needs bloom, and Hyprland's `glow` is exactly that: a coloured halo
-- around the focused window. Combined with a magenta->cyan gradient border
-- it does most of the work of the look.
--
-- Motion is showy on purpose — this is the one rice where a bit of overshoot
-- is the point. Windows slide in with a springy arrival; workspaces wipe.

return {
    general = {
        gaps_in  = 5,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(ff2e97ff)", "rgba(b967ffff)", "rgba(00f0ffff)" }, angle = 45 },
            inactive_border = "rgba(241b4dff)",
        },
    },

    decoration = {
        rounding       = 4,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.88,
        dim_inactive = true,
        dim_strength = 0.22,
        shadow = {
            enabled      = true,
            range        = 26,
            render_power = 2,
            color        = "rgba(ff2e9744)",   -- magenta bloom, not a grey drop
            color_inactive = "rgba(00000066)",
        },
        glow = {
            enabled        = true,
            range          = 12,
            render_power   = 3,
            color          = "rgba(ff2e9788)",
            color_inactive = "rgba(00000000)",
        },
        blur = {
            enabled        = true,
            size           = 6,
            passes         = 3,
            vibrancy       = 0.45,   -- push saturation, this palette wants it
            ignore_opacity = true,
        },
    },

    curves = {
        { name = "drive",  type = "bezier", points = { {0.16, 1.1}, {0.3, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "kick",   type = "spring", mass = 1, stiffness = 340, dampening = 19 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 3.5,  bezier = "drive" },
        { leaf = "border",     enabled = true, speed = 6,  bezier = "linear" },   -- slow gradient sweep
        { leaf = "windows",    enabled = true, speed = 3.5,  spring = "kick" },
        { leaf = "windowsIn",  enabled = true, speed = 3.5,  spring = "kick",  style = "slide" },
        { leaf = "windowsOut", enabled = true, speed = 2.5,  bezier = "drive", style = "slide" },
        { leaf = "fade",       enabled = true, speed = 3,  bezier = "drive" },
        { leaf = "layers",     enabled = true, speed = 3,  bezier = "drive" },
        { leaf = "layersIn",   enabled = true, speed = 3,  spring = "kick",  style = "popin 85%" },
        { leaf = "layersOut",  enabled = true, speed = 2.5,  bezier = "drive", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 3.5,  bezier = "drive", style = "slidevert" },
        { leaf = "zoomFactor", enabled = true, speed = 3,  bezier = "drive" },
    },
}

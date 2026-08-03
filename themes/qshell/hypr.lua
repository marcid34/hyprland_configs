-- QShell Showcase — Hyprland
--
-- Restrained: a hairline border in the shell's accent, a generous but even
-- gap, and motion short enough to feel instant. The desktop should not compete
-- with what is being demonstrated on it.

return {
    general = {
        gaps_in  = 5,
        gaps_out = 12,
        border_size = 1,
        col = {
            active_border   = { colors = { "rgba(5b9dffcc)", "rgba(4ade80aa)" }, angle = 30 },
            inactive_border = "rgba(222833aa)",
        },
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2.4,
        active_opacity   = 1.0,
        inactive_opacity = 0.96,
        dim_inactive = false,
        shadow = {
            enabled      = true,
            range        = 26,
            render_power = 3,
            color        = "rgba(00000066)",
        },
        blur = {
            enabled        = true,
            size           = 9,
            passes         = 3,
            vibrancy       = 0.22,
            ignore_opacity = true,
            popups         = true,
        },
    },

    curves = {
        { name = "out",    type = "bezier", points = { {0.16, 1}, {0.3, 1} } },
        { name = "inout",  type = "bezier", points = { {0.65, 0}, {0.35, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "soft",   type = "spring", mass = 1, stiffness = 260, dampening = 26 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 3.5, bezier = "out" },
        { leaf = "border",     enabled = true, speed = 3,   bezier = "out" },
        { leaf = "windows",    enabled = true, speed = 3.5, spring = "soft" },
        { leaf = "windowsIn",  enabled = true, speed = 3.5, spring = "soft",  style = "popin 94%" },
        { leaf = "windowsOut", enabled = true, speed = 3,   bezier = "out",   style = "popin 96%" },
        { leaf = "fade",       enabled = true, speed = 3,   bezier = "out" },
        { leaf = "layers",     enabled = true, speed = 3,   bezier = "out" },
        { leaf = "layersIn",   enabled = true, speed = 3,   bezier = "out",   style = "fade" },
        { leaf = "layersOut",  enabled = true, speed = 2.5, bezier = "out",   style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 3.5, bezier = "inout", style = "slidefade 12%" },
        { leaf = "zoomFactor", enabled = true, speed = 3,   bezier = "out" },
    },
}

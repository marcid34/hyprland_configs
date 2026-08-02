-- tokyonight — Hyprland
--
-- Glassy and quick. Windows arrive on a spring with a slight overshoot so
-- the motion feels responsive rather than floaty, and the gradient border
-- runs blue -> purple to match the bar's accent pair.

return {
    general = {
        gaps_in  = 5,
        gaps_out = 14,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(7aa2f7ee)", "rgba(bb9af7ee)" }, angle = 45 },
            inactive_border = "rgba(292e42cc)",
        },
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2.2,
        active_opacity   = 1.0,
        inactive_opacity = 0.92,
        dim_inactive = false,
        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            color        = "rgba(0d0e14cc)",
        },
        blur = {
            enabled        = true,
            size           = 8,
            passes         = 3,
            vibrancy       = 0.25,
            ignore_opacity = true,
            popups         = true,
        },
    },

    curves = {
        { name = "snap",   type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } },
        { name = "glide",  type = "bezier", points = { {0.25, 1}, {0.5, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "pop",    type = "spring", mass = 1, stiffness = 300, dampening = 22 },
    },

    animations = {
        { leaf = "global",        enabled = true, speed = 3,    bezier = "glide" },
        { leaf = "border",        enabled = true, speed = 2.5,    bezier = "snap" },
        { leaf = "windows",       enabled = true, speed = 3,    spring = "pop" },
        { leaf = "windowsIn",     enabled = true, speed = 3,    spring = "pop",    style = "popin 88%" },
        { leaf = "windowsOut",    enabled = true, speed = 2,    bezier = "glide",  style = "popin 90%" },
        { leaf = "fade",          enabled = true, speed = 2.5,    bezier = "glide" },
        { leaf = "layers",        enabled = true, speed = 2.5,    bezier = "snap" },
        { leaf = "layersIn",      enabled = true, speed = 2.5,    bezier = "snap",   style = "popin 92%" },
        { leaf = "layersOut",     enabled = true, speed = 2,    bezier = "glide",  style = "fade" },
        { leaf = "workspaces",    enabled = true, speed = 3,    bezier = "glide",  style = "slidefade 15%" },
        { leaf = "zoomFactor",    enabled = true, speed = 2.5,    bezier = "snap" },
    },
}

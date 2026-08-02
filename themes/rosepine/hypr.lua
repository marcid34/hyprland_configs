-- rosepine — Hyprland
--
-- Unhurried. Long eased curves and a heavily damped spring so windows settle
-- rather than snap; the whole rice is about softness, and fast motion would
-- contradict it. No gradient border — a flat rose reads calmer.

return {
    general = {
        gaps_in  = 6,
        gaps_out = 18,
        border_size = 2,
        col = {
            active_border   = "rgba(ebbcbadd)",
            inactive_border = "rgba(26233aee)",
        },
    },

    decoration = {
        rounding       = 16,
        rounding_power = 2.4,
        active_opacity   = 1.0,
        inactive_opacity = 0.90,
        dim_inactive = true,
        dim_strength = 0.12,
        shadow = {
            enabled      = true,
            range        = 24,
            render_power = 4,
            color        = "rgba(12101acc)",
        },
        blur = {
            enabled        = true,
            size           = 9,
            passes         = 3,
            vibrancy       = 0.30,
            ignore_opacity = true,
            popups         = true,
        },
    },

    curves = {
        { name = "soft",   type = "bezier", points = { {0.33, 1}, {0.68, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "settle", type = "spring", mass = 1.1, stiffness = 170, dampening = 26 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 5,    bezier = "soft" },
        { leaf = "border",     enabled = true, speed = 4,    bezier = "soft" },
        { leaf = "windows",    enabled = true, speed = 5,    spring = "settle" },
        { leaf = "windowsIn",  enabled = true, speed = 5,    spring = "settle", style = "popin 92%" },
        { leaf = "windowsOut", enabled = true, speed = 4,    bezier = "soft",   style = "popin 94%" },
        { leaf = "fade",       enabled = true, speed = 4.5,  bezier = "soft" },
        { leaf = "layers",     enabled = true, speed = 4.5,    bezier = "soft" },
        { leaf = "layersIn",   enabled = true, speed = 4.5,    bezier = "soft",   style = "fade" },
        { leaf = "layersOut",  enabled = true, speed = 4,    bezier = "soft",   style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 5,    bezier = "soft",   style = "fade" },
        { leaf = "zoomFactor", enabled = true, speed = 4.5,    bezier = "soft" },
    },
}

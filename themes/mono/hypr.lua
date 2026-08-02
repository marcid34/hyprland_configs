-- mono — Hyprland
--
-- With no colour available, the focused window has to be identified by
-- *value*: a white border against near-black, and unfocused windows dimmed
-- hard. That dim is doing the job an accent colour normally does, so it is
-- set much stronger here than in any other rice.
--
-- Motion is minimal and even — Swiss design does not bounce.

return {
    general = {
        gaps_in  = 4,
        gaps_out = 14,
        border_size = 1,
        col = {
            active_border   = "rgba(ffffffff)",
            inactive_border = "rgba(2e2e2eff)",
        },
    },

    decoration = {
        rounding       = 2,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.40,   -- the only way to say "not focused" without hue
        shadow = {
            enabled      = true,
            range        = 10,
            render_power = 2,
            color        = "rgba(000000bb)",
        },
        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.0,    -- explicitly no saturation boost
        },
    },

    curves = {
        { name = "even",   type = "bezier", points = { {0.4, 0}, {0.2, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 2.5, bezier = "even" },
        { leaf = "border",     enabled = true, speed = 2, bezier = "even" },
        { leaf = "windows",    enabled = true, speed = 2.5, bezier = "even" },
        { leaf = "windowsIn",  enabled = true, speed = 2.5, bezier = "even", style = "popin 96%" },
        { leaf = "windowsOut", enabled = true, speed = 2, bezier = "even", style = "popin 96%" },
        { leaf = "fade",       enabled = true, speed = 2, bezier = "even" },
        { leaf = "layers",     enabled = true, speed = 2.2, bezier = "even" },
        { leaf = "layersIn",   enabled = true, speed = 2.2, bezier = "even", style = "fade" },
        { leaf = "layersOut",  enabled = true, speed = 1.8, bezier = "even", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 2.5, bezier = "even", style = "fade" },
        { leaf = "zoomFactor", enabled = true, speed = 2.2, bezier = "even" },
    },
}

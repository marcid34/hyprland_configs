-- oxocarbon — Hyprland
--
-- Carbon motion: IBM's motion spec is fast, linear-ish and never bouncy —
-- productivity software should not wobble. So: short durations, an
-- expressive-but-tight bezier, no springs anywhere, no blur, no shadow.
-- Square windows on a hard grid.

return {
    general = {
        gaps_in  = 2,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border   = "rgba(ee5396ff)",
            inactive_border = "rgba(262626ff)",
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.25,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    curves = {
        -- IBM Carbon "productive" easing, standard + entrance.
        { name = "productive", type = "bezier", points = { {0.2, 0}, {0.38, 0.9} } },
        { name = "entrance",   type = "bezier", points = { {0, 0}, {0.38, 0.9} } },
        { name = "exit",       type = "bezier", points = { {0.2, 0}, {1, 1} } },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 2,  bezier = "productive" },
        { leaf = "border",     enabled = true, speed = 1.2, bezier = "productive" },
        { leaf = "windows",    enabled = true, speed = 2,  bezier = "productive" },
        { leaf = "windowsIn",  enabled = true, speed = 2,  bezier = "entrance", style = "slide" },
        { leaf = "windowsOut", enabled = true, speed = 1.5,  bezier = "exit",     style = "slide" },
        { leaf = "fade",       enabled = true, speed = 1.5,  bezier = "productive" },
        { leaf = "layers",     enabled = true, speed = 1.8,  bezier = "entrance" },
        { leaf = "layersIn",   enabled = true, speed = 1.8,  bezier = "entrance", style = "slide" },
        { leaf = "layersOut",  enabled = true, speed = 1.4,  bezier = "exit",     style = "slide" },
        { leaf = "workspaces", enabled = true, speed = 2,  bezier = "productive", style = "slide" },
        { leaf = "zoomFactor", enabled = true, speed = 1.8,  bezier = "productive" },
    },
}

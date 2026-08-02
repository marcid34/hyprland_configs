-- amber — Hyprland
--
-- A CRT has no compositor. Everything snaps: near-instant linear motion,
-- no springs, no fades on windows, no blur, no shadow, no rounding. The one
-- concession to the modern stack is `glow`, which is the closest thing
-- Hyprland has to phosphor bloom around the focused window.
--
-- If you want to go further: decoration.screen_shader accepts a GLSL file,
-- and a scanline/curvature shader over this palette is the whole look. See
-- coolwidgets.txt for where to get one.

return {
    general = {
        gaps_in  = 2,
        gaps_out = 6,
        border_size = 1,
        col = {
            active_border   = "rgba(ffb000ff)",
            inactive_border = "rgba(2b2116ff)",
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.35,   -- unfocused windows sit further from the gun
        shadow = { enabled = false },
        blur   = { enabled = false },
        glow = {
            enabled        = true,
            range          = 6,
            render_power   = 2,
            color          = "rgba(ffb00066)",
            color_inactive = "rgba(00000000)",
        },
    },

    curves = {
        { name = "instant", type = "bezier", points = { {0, 1}, {0, 1} } },
        { name = "linear",  type = "bezier", points = { {0, 0}, {1, 1} } },
    },

    animations = {
        { leaf = "global",     enabled = true,  speed = 1, bezier = "instant" },
        { leaf = "border",     enabled = true,  speed = 0.6, bezier = "instant" },
        { leaf = "windows",    enabled = true,  speed = 1, bezier = "instant" },
        { leaf = "windowsIn",  enabled = false, speed = 1, bezier = "instant" },
        { leaf = "windowsOut", enabled = false, speed = 1, bezier = "instant" },
        { leaf = "fade",       enabled = false, speed = 1, bezier = "instant" },
        { leaf = "layers",     enabled = true,  speed = 0.8, bezier = "instant" },
        { leaf = "layersIn",   enabled = false, speed = 0.8, bezier = "instant" },
        { leaf = "layersOut",  enabled = false, speed = 0.8, bezier = "instant" },
        { leaf = "workspaces", enabled = true,  speed = 1, bezier = "instant", style = "slide" },
        { leaf = "zoomFactor", enabled = true,  speed = 1, bezier = "instant" },
    },
}

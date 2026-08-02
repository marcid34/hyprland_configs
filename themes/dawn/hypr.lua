-- dawn — Hyprland
--
-- Light rice, so the compositor settings invert their usual roles:
--   * shadow is the primary separator, not the border (a hairline on a pale
--     window is invisible; a soft shadow is what makes it read as raised)
--   * inactive windows *dim* rather than fade, because reducing opacity on
--     a light window just makes it whiter and less distinguishable
--   * blur is off — blurring a light surface over a light wallpaper produces
--     mush with no edge at all

return {
    general = {
        gaps_in  = 6,
        gaps_out = 16,
        border_size = 2,
        col = {
            active_border   = "rgba(286983ee)",
            inactive_border = "rgba(dfdad9ff)",
        },
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2.2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.16,
        shadow = {
            enabled      = true,
            range        = 22,
            render_power = 3,
            color        = "rgba(57527936)",
        },
        blur = { enabled = false },
    },

    curves = {
        { name = "paper",  type = "bezier", points = { {0.22, 1}, {0.36, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "lift",   type = "spring", mass = 1, stiffness = 200, dampening = 25 },
    },

    animations = {
        { leaf = "global",     enabled = true, speed = 4.5,   bezier = "paper" },
        { leaf = "border",     enabled = true, speed = 3.5,   bezier = "paper" },
        { leaf = "windows",    enabled = true, speed = 4.5,   spring = "lift" },
        { leaf = "windowsIn",  enabled = true, speed = 4.5,   spring = "lift",  style = "popin 93%" },
        { leaf = "windowsOut", enabled = true, speed = 3.5,   bezier = "paper", style = "popin 95%" },
        { leaf = "fade",       enabled = true, speed = 4,   bezier = "paper" },
        { leaf = "layers",     enabled = true, speed = 4,   bezier = "paper" },
        { leaf = "layersIn",   enabled = true, speed = 4,   bezier = "paper", style = "popin 95%" },
        { leaf = "layersOut",  enabled = true, speed = 3.5,   bezier = "paper", style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 4.5,   bezier = "paper", style = "slidefade 10%" },
        { leaf = "zoomFactor", enabled = true, speed = 4,   bezier = "paper" },
    },
}

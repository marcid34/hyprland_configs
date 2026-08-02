-- kib-custom — Hyprland styling
--
-- Translucent floating islands: soft 10px rounding, a hairline surface1
-- border with a mauve->blue gradient on focus, gentle blur behind
-- everything. The compositor equivalent of the waybar pills.
--
-- Consumed by hyprland.lua via dofile(); returns only look-and-feel keys,
-- never behaviour, so switching a rice can't change how the WM acts.

return {
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border   = { colors = { "rgba(cba6f7ee)", "rgba(89b4faee)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)",
        },
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        dim_inactive = false,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            sharp        = false,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
}

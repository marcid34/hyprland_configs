-- slate — Hyprland styling
--
-- Restrained and dense. Small uniform rounding, tight gaps, a flat blue
-- focus border with no gradient, and just enough blur to soften the
-- wallpaper without turning it into an effect. Inactive windows sit at 0.97
-- rather than 1.0 — barely perceptible on its own, but it gives the focused
-- window a subtle lift without the heavy dimming haze uses.

return {
    general = {
        gaps_in  = 3,
        gaps_out = 8,

        border_size = 1,

        col = {
            active_border   = "rgba(89b4faff)",
            inactive_border = "rgba(313244ff)",
        },
    },

    decoration = {
        rounding       = 4,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.97,

        dim_inactive = false,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 2,
            sharp        = false,
            color        = "rgba(11111baa)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 2,
            vibrancy = 0.1,
        },
    },
}

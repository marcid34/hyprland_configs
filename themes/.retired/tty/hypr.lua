-- tty — Hyprland styling
--
-- A tiling console. Square corners, a 1px phosphor-green border, and no
-- compositing effects whatsoever: no blur, no shadow, no opacity. Tight
-- uniform gaps so the screen reads as a grid of terminals.

return {
    general = {
        gaps_in  = 3,
        gaps_out = 6,

        border_size = 1,

        col = {
            active_border   = "rgba(a6e3a1ff)",
            inactive_border = "rgba(313244ff)",
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        dim_inactive = false,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },
}

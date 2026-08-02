-- brutal — Hyprland styling
--
-- Zero rounding, a 4px hard border, and a sharp offset shadow with no
-- falloff. Blur is off entirely: this rice has no translucency for it to
-- act on, and the flat slab look depends on edges staying crisp.

return {
    general = {
        gaps_in  = 0,
        gaps_out = 6,

        border_size = 4,

        col = {
            -- Flat yellow, no gradient — gradients are a soft-edge idea.
            active_border   = "rgba(f9e2afff)",
            inactive_border = "rgba(45475aff)",
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        dim_inactive = false,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 1,
            sharp        = true,     -- hard edge, no gradient falloff
            offset       = { 6, 6 },
            color        = "rgba(11111bff)",
        },

        blur = {
            enabled = false,
        },
    },
}

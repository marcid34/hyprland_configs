-- haze — Hyprland styling
--
-- The blur does the work here. Windows are deliberately not fully opaque
-- even when focused, gaps are wide enough to see the wallpaper breathe
-- between them, and rounding is large enough to read as a lozenge rather
-- than a rectangle with soft corners.
--
-- dim_inactive is on: with everything translucent, dimming is the only
-- cue left that reliably says "this window is not focused".

return {
    general = {
        gaps_in  = 8,
        gaps_out = 22,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(f5c2e7cc)", "rgba(89b4facc)" }, angle = 30 },
            inactive_border = "rgba(31324466)",
        },
    },

    decoration = {
        rounding       = 20,
        rounding_power = 2.4,

        active_opacity   = 0.94,
        inactive_opacity = 0.80,

        dim_inactive = true,
        dim_strength = 0.18,

        shadow = {
            enabled      = true,
            range        = 28,
            render_power = 3,
            sharp        = false,
            color        = "rgba(11111b99)",
        },

        blur = {
            enabled        = true,
            size           = 12,
            passes         = 4,
            vibrancy       = 0.32,
            ignore_opacity = true,   -- blur behind the translucent fill too
        },
    },
}

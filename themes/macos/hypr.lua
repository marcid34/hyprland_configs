-- Mac OS X — Hyprland
-- macOS — translucent menubar up top, magnified dock below.
-- speed is a DURATION in ds (1ds = 100ms): higher is slower.
return {
    general = {
        gaps_in = 6, gaps_out = 14,
        border_size = 0,
        col = { active_border = "rgba(0a84ffff)",
                 inactive_border = "rgba(3a3a3cff)" },
    },
    decoration = {
        rounding = 10, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 0.95,
        dim_inactive = false,
        shadow = { enabled = true, range = 30,
                    render_power = 3,
                    color = "rgba(000000aa)" },
        blur = { enabled = true,
                  size = 10, passes = 3,
                  vibrancy = 0.25, ignore_opacity = true, popups = true },
    },
    curves = {
        { name = "os", type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "pop", type = "spring", mass = 1, stiffness = 200,
           dampening = 26 },
    },
    animations = {
        { leaf = "global",     enabled = true, speed = 3.5, bezier = "os" },
        { leaf = "border",     enabled = true, speed = 3.5, bezier = "os" },
        { leaf = "windows",    enabled = true, speed = 3.5, spring = "pop" },
        { leaf = "windowsIn",  enabled = true, speed = 3.5, spring = "pop",
           style = "popin 80%" },
        { leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "os",
           style = "popin 92%" },
        { leaf = "fade",       enabled = true, speed = 2.5, bezier = "os" },
        { leaf = "layers",     enabled = true, speed = 3.5, bezier = "os" },
        { leaf = "layersIn",   enabled = true, speed = 3.5, bezier = "os",
           style = "popin 92%" },
        { leaf = "layersOut",  enabled = true, speed = 2.5, bezier = "os",
           style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 3.5, bezier = "os",
           style = "slidefade 15%" },
        { leaf = "zoomFactor", enabled = true, speed = 3.5, bezier = "os" },
    },
}

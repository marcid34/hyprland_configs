-- Windows 11 Pro — Hyprland
-- Windows 11 — centred taskbar, Mica surfaces, Fluent blue.
-- speed is a DURATION in ds (1ds = 100ms): higher is slower.
return {
    general = {
        gaps_in = 4, gaps_out = 8,
        border_size = 1,
        col = { active_border = "rgba(0078d4ff)",
                 inactive_border = "rgba(3d3d3dff)" },
    },
    decoration = {
        rounding = 8, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 1.0,
        dim_inactive = false,
        shadow = { enabled = true, range = 14,
                    render_power = 3,
                    color = "rgba(00000077)" },
        blur = { enabled = false,
                  size = 6, passes = 3,
                  vibrancy = 0.25, ignore_opacity = true, popups = true },
    },
    curves = {
        { name = "os", type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "pop", type = "spring", mass = 1, stiffness = 260,
           dampening = 24 },
    },
    animations = {
        { leaf = "global",     enabled = true, speed = 2, bezier = "os" },
        { leaf = "border",     enabled = true, speed = 2, bezier = "os" },
        { leaf = "windows",    enabled = true, speed = 2, spring = "pop" },
        { leaf = "windowsIn",  enabled = true, speed = 2, spring = "pop",
           style = "popin 88%" },
        { leaf = "windowsOut", enabled = true, speed = 1, bezier = "os",
           style = "popin 92%" },
        { leaf = "fade",       enabled = true, speed = 1, bezier = "os" },
        { leaf = "layers",     enabled = true, speed = 2, bezier = "os" },
        { leaf = "layersIn",   enabled = true, speed = 2, bezier = "os",
           style = "popin 92%" },
        { leaf = "layersOut",  enabled = true, speed = 1, bezier = "os",
           style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 2, bezier = "os",
           style = "slide" },
        { leaf = "zoomFactor", enabled = true, speed = 2, bezier = "os" },
    },
}

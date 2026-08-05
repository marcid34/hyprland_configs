-- ember — Hyprland
-- Banked heat. Amber falling into rose, nothing fully cooled.
--
-- speed is a DURATION in ds (1ds = 100ms): higher is slower.
--
-- Windows get a spring and everything else gets a front-loaded bezier. That
-- is the same enter/exit split the shell uses: a window appearing is a
-- physical event and should overshoot slightly, while a workspace slide is
-- navigation and should simply be over.
return {
    general = {
        gaps_in = 5, gaps_out = 12,
        border_size = 2,
        col = { active_border = "rgba(ff9d4dff)",
                 inactive_border = "rgba(322722ff)" },
    },
    decoration = {
        rounding = 14, rounding_power = 2.6,
        active_opacity = 1.0, inactive_opacity = 0.94,
        dim_inactive = true, dim_strength = 0.10,
        shadow = { enabled = true,
                    range = 24, render_power = 3,
                    color = "rgba(0000006b)" },
        blur = { enabled = true,
                  size = 8, passes = 3, vibrancy = 0.19,
                  new_optimizations = true, ignore_opacity = true },
    },
    curves = {
        -- Mirrors Theme.qml: `enter` is front-loaded, `exit` is plain ease.
        { name = "enter", type = "bezier", points = { {0.16, 1}, {0.3, 1} } },
        { name = "exit",  type = "bezier", points = { {0.33, 1}, {0.68, 1} } },
        { name = "linear", type = "bezier", points = { {0, 0}, {1, 1} } },
        { name = "spring", type = "spring", mass = 1, stiffness = 340,
           dampening = 26 },
    },
    animations = {
        { leaf = "global",     enabled = true, speed = 2, bezier = "enter" },
        { leaf = "border",     enabled = true, speed = 3, bezier = "enter" },
        { leaf = "windows",    enabled = true, speed = 2, spring = "spring" },
        { leaf = "windowsIn",  enabled = true, speed = 2, spring = "spring",
           style = "popin 92%" },
        { leaf = "windowsOut", enabled = true, speed = 1, bezier = "exit",
           style = "popin 94%" },
        { leaf = "fade",       enabled = true, speed = 1, bezier = "enter" },
        { leaf = "layers",     enabled = true, speed = 2, bezier = "enter" },
        { leaf = "layersIn",   enabled = true, speed = 2, bezier = "enter",
           style = "popin 94%" },
        { leaf = "layersOut",  enabled = true, speed = 1, bezier = "exit",
           style = "fade" },
        { leaf = "workspaces", enabled = true, speed = 2, bezier = "enter",
           style = "slidefade 15%" },
        { leaf = "zoomFactor", enabled = true, speed = 2, bezier = "enter" },
    },
}

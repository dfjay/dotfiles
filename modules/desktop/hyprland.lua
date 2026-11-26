local nix = require("nix")
local ipc = nix.noctalia .. " msg "

hl.env("XCURSOR_THEME", nix.cursor.name)
hl.env("XCURSOR_SIZE",  nix.cursor.size)

-- Same keys as aerospace on macOS, with SUPER in place of alt.
local mod = "SUPER"

-- Same monitors as aerospace's workspace-to-monitor-force-assignment.
local ultrawide   = "desc:Dell Inc. DELL U4025QW"
local touchscreen = "desc:Woodwind Communications Systems Inc SU13TO"
local touchscreenPort = "HDMI-A-1"

-- 5120x2160@120, the EDID preferred mode is only 60 Hz.
hl.monitor({
    output   = ultrawide,
    mode     = "highrr",
    position = "0x0",
    scale    = 1.25,
})

-- 13" touch panel, 4K@60 preferred. highrr would pick 800x600@60.32.
hl.monitor({
    output   = touchscreen,
    mode     = "preferred",
    -- Centered under the ultrawide: (4096 - 1536) / 2, below its 1728 logical rows.
    position = "1280x1728",
    scale    = 2.5,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.config({
    general = {
        -- gaps_in applies per window side: 4 + 4 between windows matches gaps_out.
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 1,
        col = {
            active_border   = "rgba(ffffff30)",
            inactive_border = "rgba(ffffff12)",
        },
        layout      = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 3,
        dim_inactive   = true,
        dim_strength   = 0.08,

        shadow = {
            enabled        = true,
            range          = 40,
            render_power   = 3,
            offset         = { 0, 10 },
            color          = "rgba(00000070)",
            color_inactive = "rgba(00000038)",
        },

        blur = {
            enabled  = true,
            size     = 10,
            passes   = 3,
            noise    = 0.02,
            vibrancy = 0.2,
            popups   = true,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    input = {
        kb_layout    = "us,ru",
        kb_options   = "caps:escape",
        repeat_delay = 300,
        repeat_rate  = 33,
        follow_mouse = 1,
        -- Touch otherwise maps onto the whole layout, not the touch panel.
        -- Input output mapping takes a connector, not desc:.
        touchdevice  = {
            output = touchscreenPort,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        vrr = 2,
    },

    render = {
        direct_scanout = 2,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.curve("easeOut", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3.5, bezier = "easeOut", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "easeOut", style = "popin 92%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2.5, bezier = "easeOut" })
hl.animation({ leaf = "border",     enabled = true, speed = 3,   bezier = "easeOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOut", style = "slide" })

-- The panel also exposes an absolute pointer next to its multitouch node.
hl.device({
    name   = "ilitek-ilitek-tp-mouse",
    output = touchscreenPort,
})

-- Persistent workspaces 1-9, like aerospace's persistent-workspaces:
-- 1-7 on the ultrawide, 8-9 on the touch panel.
for i = 1, 9 do
    hl.workspace_rule({
        workspace  = tostring(i),
        persistent = true,
        monitor    = i <= 7 and ultrawide or touchscreen,
        default    = i == 1 or i == 8,
    })
end

---- Apps ----

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(nix.terminal))
hl.bind("ALT + Space",      hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mod .. " + S",      hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mod .. " + comma",  hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(ipc .. "session lock"))

hl.bind("Print",                 hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(mod .. " + SHIFT + S",   hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("SHIFT + Print",         hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("ALT + Print",           hl.dsp.exec_cmd(ipc .. "screenshot-window"))

hl.bind("ALT + Tab",         hl.dsp.exec_cmd(ipc .. "window-switcher hold"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold reverse"))

---- Windows ----

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
    hl.bind(mod .. " + " .. key,           hl.dsp.focus({ direction = direction }))
    hl.bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ direction = direction }))
end

hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }), { repeating = true })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---- Workspaces ----

for i = 1, 9 do
    hl.bind(mod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mod .. " + Tab",         hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.workspace.move({ monitor = "+1" }))

---- Service mode (aerospace's alt-shift-semicolon) ----

hl.bind(mod .. " + SHIFT + semicolon", hl.dsp.submap("service"))

hl.define_submap("service", function()
    hl.bind("Escape", function()
        hl.dispatch(hl.dsp.reload_config())
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("F", function()
        hl.dispatch(hl.dsp.window.float())
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("R", function()
        hl.dispatch(hl.dsp.layout("togglesplit"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SHIFT + E", hl.dsp.exit())
end)

---- Media keys ----

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(ipc .. "volume-mute"),  { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(ipc .. "mic-mute"),     { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd(ipc .. "media next"),   { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })

---- Rules ----

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.window_rule({
    name  = "noctalia-settings",
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size  = { 1080, 920 },
})

local noctaliaLayers = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"

hl.layer_rule({
    name    = "noctalia-no-anim",
    match   = { namespace = noctaliaLayers },
    no_anim = true,
})

hl.layer_rule({
    name        = "noctalia-blur",
    match       = { namespace = noctaliaLayers },
    blur        = true,
    blur_popups = true,
    ignore_alpha = 0.5,
})

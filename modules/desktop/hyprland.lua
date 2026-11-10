-- Hyprland config, loaded from the hyprland.lua that home-manager generates.
-- Colors come from stylix (hl.config in that file), store paths from nix.lua.
-- Reference: https://wiki.hypr.land/configuring/

local nix = require("nix")
local ipc = nix.noctalia .. " msg "

-- Same keys as aerospace on macOS, with SUPER in place of alt.
local mod = "SUPER"

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
    -- Fullscreen HDR content switches the output to HDR on its own
    -- (render.cm_auto_hdr). For HDR on the desktop too, add:
    -- cm = "hdr", bitdepth = 10,
})

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 5,
        border_size = 2,
        layout      = "dwindle",
    },

    decoration = {
        rounding = 10,
    },

    dwindle = {
        preserve_split = true,
    },

    input = {
        kb_layout    = "us,ru",
        kb_options   = "grp:caps_toggle",
        follow_mouse = 1,
    },

    misc = {
        force_default_wallpaper = 0,
        -- Adaptive sync only for fullscreen windows (games).
        vrr = 2,
    },

    render = {
        -- Lower latency for fullscreen games.
        direct_scanout = 2,
    },
})

-- Persistent workspaces 1-9, like aerospace's persistent-workspaces.
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

---- Autostart ----
-- noctalia, polkit agent and hypridle run as systemd user services.

---- Apps ----

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(nix.terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mod .. " + S",      hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mod .. " + comma",  hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(ipc .. "session lock"))

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
    -- Flip the split direction of the focused pair (dwindle only).
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

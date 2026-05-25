local programs = require("programs")
local mod = "SUPER"

-- Apps
hl.bind(mod .. " + Return",     hl.dsp.exec_cmd(programs.terminal))
hl.bind(mod .. " + Space",      hl.dsp.exec_cmd(programs.menu))
hl.bind(mod .. " + E",          hl.dsp.exec_cmd(programs.file_manager))
hl.bind(mod .. " + B",          hl.dsp.exec_cmd(programs.browser))
hl.bind(mod .. " + SHIFT + B",  hl.dsp.exec_cmd(programs.browser_private))

-- Window
hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mod .. " + backslash", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Session
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

-- Wallpaper (via quickshell IPC)
hl.bind(mod .. " + W",         hl.dsp.exec_cmd("qs ipc call wallpaper next"))
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("qs ipc call wallpaper random"))

-- Toggle layout (dwindle <-> scrolling)
hl.bind(mod .. " + T", function()
    local cur = hl.get_config("general.layout")
    local next_layout = (cur == "dwindle") and "scrolling" or "dwindle"
    hl.config({ general = { layout = next_layout } })
    hl.notification.create({ text = "layout: " .. next_layout, timeout = 1500, icon = "ok" })
end)

-- Focus (vim hjkl)
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move active window (SHIFT + hjkl)
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Resize submap: Super+R to enter, hjkl to resize, Esc to exit
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local step = 40
    hl.bind("H", hl.dsp.window.resize({ x = -step, y = 0,     relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = step,  y = 0,     relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0,     y = -step, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0,     y = step,  relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Workspaces 1..10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Drag / resize with mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia / brightness (locked = active on lockscreen too)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

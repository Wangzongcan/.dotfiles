-- Hyprland entry point.
-- Each require() is an isolated Lua scope: an error in one module won't
-- prevent the others from loading (https://wiki.hypr.land/Configuring/Start/).

require("monitors")
require("env")
require("look")
require("input")
require("binds")
require("rules")
require("autostart")

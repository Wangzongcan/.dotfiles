local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_close_confirmation = 'NeverPrompt'

config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 4,
  right = 4,
  top = 0,
  bottom = 0,
}

config.font = wezterm.font_with_fallback {
   'Jetbrains Mono',
   'PingFang SC',
   'Arial Unicode MS',
}

config.color_scheme = 'Molokai'

return config

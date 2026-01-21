local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.automatically_reload_config = true

-- fonts
config.font_size = 14
config.font = wezterm.font_with_fallback({
  { family = "IntoneMono Nerd Font" },
  { family = "Hiragino Kaku Gothic Pro" },
})
config.use_ime = true

-- visual
config.color_scheme = "SpaceGray Eighties Dull"
config.window_background_opacity = 0.85     -- 不透明度
config.macos_window_background_blur = 20    -- ぼかし
config.window_decorations = "RESIZE"        -- ヘッダー非表示
config.hide_tab_bar_if_only_one_tab = false -- タブが1つの時も表示
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.colors = {
  background = "#2A2C3C", -- ペインの背景色（inactive_pane_hsb が効くようにする）
  tab_bar = {
    inactive_tab_edge = "none",
  },
  split = "#BABBF1", -- ペイン境界線を目立たせる
}

-- 非アクティブペインを暗くしてアクティブペインを目立たせる
config.inactive_pane_hsb = {
  hue = 0.9,        -- 色相をずらしてグレー調に
  saturation = 0.5, -- 彩度を大幅に下げる
  brightness = 0.5, -- 暗くする
}
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"

  if tab.is_active then
    background = "#BABBF1"
    foreground = "#000000"
  end

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

-- position & size
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.disable_default_key_bindings = true

return config

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
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE"        -- ヘッダー非表示
config.audible_bell = "Disabled"            -- toast通知と二重にならないようシステムビープを無効化
config.hide_tab_bar_if_only_one_tab = false -- タブが1つの時も表示
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
-- ANSI の白が前景色より暗い (#bac2de / #a6adc8) ため、ANSI テーマの Claude Code 等が
-- 暗く見える。組み込みスキームの白だけ明るくして使う
local mocha = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
mocha.ansi[8] = "#cdd6f4"
mocha.brights[8] = "#ffffff"

config.colors = {
  ansi = mocha.ansi,
  brights = mocha.brights,
  background = "#1e1e2e", -- ペインの背景色（inactive_pane_hsb が効くようにする）
  tab_bar = {
    inactive_tab_edge = "none",
  },
  split = "#b4befe", -- ペイン境界線を目立たせる
}

-- 非アクティブペインを暗くしてアクティブペインを目立たせる
config.inactive_pane_hsb = {
  hue = 0.9,        -- 色相をずらしてグレー調に
  saturation = 0.5, -- 彩度を大幅に下げる
  brightness = 0.5, -- 暗くする
}
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#45475a"
  local foreground = "#cdd6f4"

  if tab.is_active then
    background = "#b4befe"
    foreground = "#11111b"
  end

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

-- Claude Code の hook が送る BEL を toast 通知に変換する
-- (端末タイトルには hook 側で OSC 0 によりメッセージ本文がセットされている)
wezterm.on("bell", function(window, pane)
  local process_info = pane:get_foreground_process_info()
  local process_name = process_info and process_info.name or ""
  if process_name:lower():find("claude") then
    window:toast_notification("Claude Code", pane:get_title(), nil, 4000)
  end
end)

-- position & size
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.disable_default_key_bindings = true

return config

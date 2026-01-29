{ ... }:

{
  # WezTerm: Homebrew caskで管理（darwin.nix参照）

  xdg.configFile = {
    "wezterm/wezterm.lua".source = ../config/wezterm/wezterm.lua;
    "wezterm/keybinds.lua".source = ../config/wezterm/keybinds.lua;
  };
}

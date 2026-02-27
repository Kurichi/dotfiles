{ profile, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    caskArgs.appdir = "/Applications";
    casks = [
      "1password"
      "adobe-acrobat-reader"
      "homerow"
      "orbstack"
      "raycast"
      "wezterm@nightly"
    ] ++ (profile.homebrew.casks or []);
    masApps = profile.homebrew.masApps or {};
  };
}

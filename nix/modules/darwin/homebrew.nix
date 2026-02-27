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
      "homerow"
      "raycast"
      "wezterm@nightly"
    ] ++ (profile.homebrew.casks or []);
    masApps = profile.homebrew.masApps or {};
  };
}

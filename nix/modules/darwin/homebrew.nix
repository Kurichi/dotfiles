{ profile, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    caskArgs.appdir = "/Applications";
    taps = [
      "datadog-labs/pack"
    ];
    brews = [
      "mise"
      "datadog-labs/pack/pup"
    ];
    casks = [
      "1password"
      "homerow"
      "raycast"
      "wezterm@nightly"
    ] ++ (profile.homebrew.casks or []);
    masApps = profile.homebrew.masApps or {};
  };
}

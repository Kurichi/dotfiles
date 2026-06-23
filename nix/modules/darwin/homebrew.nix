{ profile, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # cleanup は一旦無効化（最近の Homebrew では `brew bundle --cleanup` が --force 必須になり活性化が失敗するため）
      cleanup = "none";
    };
    caskArgs.appdir = "/Applications";
    taps = [
      "datadog-labs/pack"
      "jakehilborn/jakehilborn"
    ];
    brews = [
      "mise"
      "datadog-labs/pack/pup"
      "jakehilborn/jakehilborn/displayplacer"
    ];
    casks = [
      "1password"
      "homerow"
      "proton-pass"
      "raycast"
      "wezterm@nightly"
    ] ++ (profile.homebrew.casks or []);
    masApps = profile.homebrew.masApps or {};
  };
}

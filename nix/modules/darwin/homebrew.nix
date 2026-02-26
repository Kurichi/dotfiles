_: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Remove undeclared packages and their associated files
    };
    caskArgs.appdir = "/Applications";
    casks = [
      "1password"
      "adobe-acrobat-reader"
      "datagrip"
      "discord"
      "google-drive"
      "homerow"
      "orbstack"
      "postman-agent"
      "raycast"
      "slack"
      "steam"
      "wezterm@nightly"
      "zoom"
    ];
    masApps = {
      LINE = 539883307;
    };
  };
}

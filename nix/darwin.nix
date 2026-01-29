{ pkgs, username, hostname, ... }:

{
  # Nix settings (Determinate Nix manages the daemon)
  nix.enable = false;

  # System packages (CLIツールはhome.nixで管理)
  environment.systemPackages = with pkgs; [
  ];

  # Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "none";  # Keep existing packages not in this list
    };
    caskArgs.appdir = "/Applications";
    casks = [
      "1password"
      "adobe-acrobat-reader"
      "datagrip"
      "discord"
      "doll"
      "google-drive"
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

  # Primary user (required for system.defaults options)
  system.primaryUser = username;

  # macOS system settings
  system = {
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      controlcenter = {
        BatteryShowPercentage = true;
      };
    };
    # Used for backwards compatibility
    stateVersion = 5;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Users
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Enable sudo with Touch ID (new syntax)
  security.pam.services.sudo_local.touchIdAuth = true;

  # Set hostname
  networking.hostName = hostname;
}

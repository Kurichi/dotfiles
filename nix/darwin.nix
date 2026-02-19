{ pkgs, lib, profile, ... }:
let
  inherit (profile) username hostname passwordManager;

  passwordManagerCask = {
    "1password" = "1password";
    "bitwarden" = "bitwarden";
  }.${passwordManager};
in
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
      cleanup = "zap";  # Remove undeclared packages and their associated files
    };
    caskArgs.appdir = "/Applications";
    casks = [
      passwordManagerCask
      "adobe-acrobat-reader"
      "doll"
      "google-drive"
      "orbstack"
      "raycast"
      "wezterm@nightly"
    ] ++ profile.extraCasks;
    masApps = {} // profile.extraMasApps;
  };

  # Primary user (required for system.defaults options)
  system.primaryUser = username;

  # macOS system settings
  system = {
    defaults = {
      dock = {
        autohide = false;
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
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };
      controlcenter = {
        BatteryShowPercentage = true;
      };
    };
    # Used for backwards compatibility
    stateVersion = 5;
  };

  # Power management
  power.sleep.display = "never";

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

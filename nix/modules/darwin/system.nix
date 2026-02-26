{ username, hostname, ... }:

{
  # Primary user (required for system.defaults options)
  system.primaryUser = username;

  # macOS system settings
  system.defaults = {
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

  # Power management
  power.sleep.display = "never";

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

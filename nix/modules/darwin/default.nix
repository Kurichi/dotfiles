{ ... }:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Nix settings (Determinate Nix manages the daemon)
  nix.enable = false;

  # System packages (CLIツールはhome/packages.nixで管理)
  environment.systemPackages = [];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility
  system.stateVersion = 5;
}

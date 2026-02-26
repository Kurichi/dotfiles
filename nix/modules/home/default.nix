{ ... }:

{
  imports = [
    ./packages.nix
    ./dotfiles.nix
    ./launchd.nix
    ./programs
  ];

  # Home Manager state version
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}

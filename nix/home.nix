{ config, pkgs, llmPkgs, ... }:

{
  imports = [
    ./git.nix
    ./fish.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # User packages
  home.packages = with pkgs; [
    # CLI tools
    ripgrep
    fd
    bat
    eza
    fzf
    ghq
    jq
    tree

    # Development
    nodejs
    nodePackages.pnpm
    bun
    uv
    go

    # Git tools
    gh
    lazygit

    # AI tools
    llmPkgs.claude-code
  ];

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}

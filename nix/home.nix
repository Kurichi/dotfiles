{ config, pkgs, llmPkgs, weztermPkg, ... }:

{
  imports = [
    ./git.nix
    ./fish.nix
    ./vscode.nix
    ./wezterm.nix
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

    # AWS
    ssm-session-manager-plugin

    # Tools
    tailscale
    valkey
    xcode-install

    # GUI Apps
    discord
    slack
    orbstack
    jetbrains.datagrip
    zoom-us

    # Fonts
    nerd-fonts.hack
    nerd-fonts.intone-mono
    noto-fonts-cjk-sans
  ];

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}

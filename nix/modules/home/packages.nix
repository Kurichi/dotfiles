{ pkgs, llmPkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI tools
    ripgrep
    fd
    bat
    eza
    fzf
    ghq
    jq
    just
    tree
    tmux

    # Development
    nodejs
    nodePackages.pnpm
    bun
    uv
    go_1_26
    rustup

    # Git tools
    gh
    lazygit
    gwq
    # pkgs."git-wt"  # TODO: nixpkgs更新後に戻す

    # AI tools
    pkgs.claude-code
    llmPkgs.codex
    llmPkgs.gemini-cli
    llmPkgs.copilot-cli
    moreutils  # sponge コマンド（設定ファイルの in-place 更新用）

    # AWS
    awscli2
    ssm-session-manager-plugin

    # Infrastructure
    terraform

    # Linters
    actionlint
    shellcheck

    # Build tools
    ninja

    # PDF tools
    pkgs."poppler-utils"  # pdftotext, pdftoppm 等

    # Tools
    tailscale
    valkey
    xcode-install
    opensc

    # GUI Apps: Homebrew casksで管理（darwin/homebrew.nix参照）

    # Fonts
    nerd-fonts.hack
    nerd-fonts.intone-mono
    noto-fonts-cjk-sans
  ];
}

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
    git-wt

    # AI tools
    (pkgs.claude-code.overrideAttrs (old: {
      postFixup = builtins.replaceStrings
        [
          "--set DISABLE_TELEMETRY 1"
          "--set DISABLE_NON_ESSENTIAL_MODEL_CALLS 1"
          "--set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1"
        ]
        [ "" "" "" ]
        old.postFixup;
    }))
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

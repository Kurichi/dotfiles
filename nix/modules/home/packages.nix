{ pkgs, llmPkgs, profile, claudeCodePkg, ... }:

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
    xh
    just
    tree
    tmux

    # Development
    nodejs
    pnpm
    bun
    uv
    go_1_26
    rustup

    # Git tools
    gh
    lazygit
    git-wt

    # AI tools
    claudeCodePkg
    llmPkgs.gemini-cli
    llmPkgs.copilot-cli
    moreutils

    # Linters
    actionlint
    shellcheck

    # Infrastructure
    terraform
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    awscli2
    ssm-session-manager-plugin
    proton-pass-cli

    # Build tools
    ninja

    # PDF tools
    pkgs."poppler-utils"

    # Fonts
    nerd-fonts.hack
    nerd-fonts.intone-mono
    noto-fonts-cjk-sans
  ] ++ ((profile.packages or (_: [])) pkgs);
}

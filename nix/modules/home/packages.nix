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
    (claudeCodePkg.overrideAttrs (old: {
      postFixup = builtins.replaceStrings
        [
          "--set DISABLE_TELEMETRY 1"
          "--set DISABLE_NON_ESSENTIAL_MODEL_CALLS 1"
          "--set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1"
        ]
        [ "" "" "" ]
        old.postFixup;
    }))
    llmPkgs.gemini-cli
    llmPkgs.copilot-cli
    moreutils

    # Linters
    actionlint
    shellcheck

    # Infrastructure
    terraform
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

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

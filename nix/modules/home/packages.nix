{ pkgs, llmPkgs, profile, claudeCodePkg, ... }:

{
  home.packages = [
    # CLI tools
    pkgs.ripgrep
    pkgs.fd
    pkgs.bat
    pkgs.eza
    pkgs.fzf
    pkgs.ghq
    pkgs.jq
    pkgs.just
    pkgs.tree
    pkgs.tmux

    # Development
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.bun
    pkgs.uv
    pkgs.go_1_26
    pkgs.rustup

    # Git tools
    pkgs.gh
    pkgs.lazygit
    pkgs.git-wt

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
    llmPkgs.codex
    llmPkgs.gemini-cli
    llmPkgs.copilot-cli
    pkgs.moreutils

    # Linters
    pkgs.actionlint
    pkgs.shellcheck

    # Infrastructure
    pkgs.terraform
    (pkgs.google-cloud-sdk.withExtraComponents [
      pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])

    # Build tools
    pkgs.ninja

    # PDF tools
    pkgs.poppler-utils

    # Fonts
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.intone-mono
    pkgs.noto-fonts-cjk-sans
  ] ++ ((profile.packages or (_: [])) pkgs);
}

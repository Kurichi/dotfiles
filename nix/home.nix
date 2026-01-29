{ config, pkgs, llmPkgs, weztermPkg, gwqPkg, ... }:

{
  imports = [
    ./git.nix
    ./fish.nix
    ./vscode.nix
    ./wezterm.nix
    ./llm-agents.nix
    ./neovim.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.11";

  # Environment variables
  home.sessionVariables = {
    # AI Tools
    CODEX_HOME = "$HOME/.config/codex";
    CLAUDE_CONFIG_DIR = "$HOME/.config/claude";
    GEMINI_CLI_HOME = "$HOME/.config";  # ~/.config/.gemini/ に設定保存
    # pnpm
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

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
    tmux

    # Development
    nodejs
    nodePackages.pnpm
    bun
    uv
    go
    rustup

    # Git tools
    gh
    lazygit
    gwqPkg
    # pkgs."git-wt"  # TODO: nixpkgs更新後に戻す

    # AI tools
    llmPkgs.claude-code
    llmPkgs.codex
    llmPkgs.gemini-cli
    llmPkgs.copilot-cli
    moreutils  # sponge コマンド（設定ファイルの in-place 更新用）

    # AWS
    ssm-session-manager-plugin

    # Tools
    tailscale
    valkey
    xcode-install
    opensc

    # GUI Apps: Homebrew casksで管理（darwin.nix参照）

    # Fonts
    nerd-fonts.hack
    nerd-fonts.intone-mono
    noto-fonts-cjk-sans
  ];

  # gwq config
  xdg.configFile."gwq/config.toml".text = ''
    [naming]
    template = '{{.Host}}/{{.Owner}}/{{.Repository}}={{.Branch}}'

    [worktree]
    basedir = '~/repos'
  '';

  # Startup apps (launchd)
  launchd.enable = true;
  launchd.agents = {
    raycast = {
      enable = true;
      config = {
        ProgramArguments = [ "/Applications/Raycast.app/Contents/MacOS/Raycast" ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
    doll = {
      enable = true;
      config = {
        ProgramArguments = [ "/Applications/Doll.app/Contents/MacOS/Doll" ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}

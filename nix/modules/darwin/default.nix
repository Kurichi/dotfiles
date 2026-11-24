{ ... }:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Nix settings (Determinate Nix manages the daemon)
  nix.enable = false;

  # Determinate Nix の /etc/nix/nix.conf は `!include nix.custom.conf` で
  # 追加設定を読み込む。input が推奨するバイナリキャッシュを trusted に登録する。
  # - ryoppippi.cachix.org: claude-code-overlay
  # - cache.numtide.com: llm-agents（codex 等。鍵は llm-agents の flake.nix の nixConfig と同じ）
  environment.etc."nix/nix.custom.conf".text = ''
    extra-substituters = https://ryoppippi.cachix.org https://cache.numtide.com
    extra-trusted-substituters = https://ryoppippi.cachix.org https://cache.numtide.com
    extra-trusted-public-keys = ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
    !include /etc/nix/access-tokens.conf
  '';

  # Enable Fish shell system-wide (/etc/shells registration + completions)
  programs.fish.enable = true;

  # System packages (CLIツールはhome/packages.nixで管理)
  environment.systemPackages = [];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility
  system.stateVersion = 5;
}

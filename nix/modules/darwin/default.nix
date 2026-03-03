{ ... }:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Nix settings (Determinate Nix manages the daemon)
  nix.enable = false;

  # Determinate Nix の /etc/nix/nix.conf は `!include nix.custom.conf` で
  # 追加設定を読み込む。cachix substituter を trusted に登録する。
  environment.etc."nix/nix.custom.conf".text = ''
    extra-substituters = https://ryoppippi.cachix.org
    extra-trusted-substituters = https://ryoppippi.cachix.org
    extra-trusted-public-keys = ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms=
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

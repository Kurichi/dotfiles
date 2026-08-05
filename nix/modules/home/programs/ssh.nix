{ lib, profile, ... }:
let
  cfg = profile.ssh or null;
in
lib.mkIf (cfg != null) {
  # 認証用の公開鍵を Nix 管理で配置する。秘密鍵は Proton Pass の agent が保持するため、
  # ここに置くのは IdentityFile が指す公開鍵のみ。署名鍵 (~/.ssh/git-signing.pub) は
  # git.nix が別途生成する ―― 認証と署名で鍵を分離するための構成。
  home.file = lib.mapAttrs'
    (name: text: lib.nameValuePair ".ssh/${name}" { text = "${text}\n"; })
    (cfg.identityFiles or { });

  programs.ssh = {
    enable = true;

    # 既定値は `AddKeysToAgent no` / `ServerAliveInterval 0` を注入したうえで
    # ビルドのたびに非推奨警告を出す。必要な値は matchBlocks."*" に明示する。
    enableDefaultConfig = false;

    # home-manager の生成順は extraOptionOverrides -> Include -> 個別 matchBlocks -> Host *。
    # OrbStack の Include は「ファイル先頭」でなければ効かないが、この順序により構造的に保証される。
    includes = cfg.includes or [ ];

    matchBlocks = (cfg.matchBlocks or { }) // {
      # Host * は最後に出力される。ssh_config は先に読まれた値が勝つので、
      # 個別ホストの設定がここより優先される。
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 15;
        serverAliveCountMax = 30;
        # UseKeychain に対応するオプションは home-manager に存在しない
        extraOptions = {
          UseKeychain = "yes";
        };
      };
    };
  };
}

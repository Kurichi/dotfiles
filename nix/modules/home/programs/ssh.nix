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

    # true のままだと `AddKeysToAgent no` / `ServerAliveInterval 0` 等が
    # mkDefault で注入され、非推奨警告も出る。必要な既定値は settings."*" に明示する。
    enableDefaultConfig = false;

    # 生成順は extraOptionOverrides -> Include -> settings（"*" 以外, topoSort 順）-> "*"。
    # "*" は topoSort から除外され常に末尾に出力される（dag helper 不要）。
    # OrbStack の Include は「ファイル先頭」でなければ効かないが、この順序により構造的に保証される。
    includes = cfg.includes or [ ];

    settings = (cfg.settings or { }) // {
      # "*" は常に最後に出力される。ssh_config は先に読まれた値が勝つので、
      # 個別ホストの設定がここより優先される。
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 15;
        ServerAliveCountMax = 30;
        # settings は freeform なので UseKeychain もそのまま書ける（旧 extraOptions 不要）
        UseKeychain = "yes";
      };
    };
  };
}

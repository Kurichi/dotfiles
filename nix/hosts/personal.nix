{
  username = "kurichi";
  hostname = "Kurichi-MacBook-Pro";

  git = {
    userName = "Kurichi";
    userEmail = "me@kurichi.dev";
    # GitHub に認証用 / 署名用の両方で登録済みの Proton Pass 鍵
    # ("Proton Pass - Kurichi-MacBook-Pro" / SHA256:FPmyikU3yRQreSoPIl4IJCstOFOcRi+lnWV9nhkNjYE)
    signingKeyText = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyXCW68C7NXKIKY/ZPvjcDYSxTLQM4XDQ/BdkULrMEh GitHub - Kurichi-MacBook-Pro";
    # signingVaultName は意図的に未設定。これは pass-cli ssh-agent start --vault-name に渡され、
    # 署名鍵だけでなく agent が読み込む鍵全体を絞り込むため、reserpick / lab の鍵が
    # 別 vault にあると認証が壊れる。3 鍵が同一 vault だと確認できたら設定してよい。
    gpgSign = true;
  };

  # Proton 専用ソケットが落ちても署名・認証を継続できるよう、
  # macOS システム ssh-agent にも鍵を投入する（秘密鍵がログインセッション中常駐する）
  loadKeysIntoSystemAgent = true;

  ssh = {
    includes = [ "~/.orbstack/ssh/config" ];
    matchBlocks = {
      github = {
        host = "github github.com";
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/git-signing.pub";
        identityAgent = "~/.ssh/proton-pass-agent.sock";
        identitiesOnly = true;
      };
      reserpick = {
        hostname = "157.7.113.111";
        port = 1102;
        user = "y_kurihara";
        identityFile = "~/.ssh/reserpick.pub";
        identityAgent = "~/.ssh/proton-pass-agent.sock";
        identitiesOnly = true;
      };
      lab = {
        hostname = "131.206.63.6";
        port = 2019;
        user = "ykurihara";
        identityFile = "~/.ssh/lab.pub";
        identityAgent = "~/.ssh/proton-pass-agent.sock";
        identitiesOnly = true;
      };
    };
  };

  homebrew = {
    casks = [
      "adobe-acrobat-reader"
      "alt-tab"
      "claude"
      "codex"
      "discord"
      "google-chrome"
      "google-drive"
      "notion"
      "notion-calendar"
      "onedrive"
      "orbstack"
      "postman-agent"
      "proton-mail"
      "proton-drive"
      "slack"
      "steam"
      "zoom"
    ];
    masApps = {
      LINE = 539883307;
    };
  };

  packages = p: with p; [
    opensc
    tailscale
    valkey
  ];
}

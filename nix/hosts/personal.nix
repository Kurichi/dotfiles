{
  username = "kurichi";
  hostname = "Kurichi-MacBook-Pro";

  git = {
    userName = "Kurichi";
    userEmail = "me@kurichi.dev";
    # 署名専用の Proton Pass 鍵 ("GitHub Signing - Kurichi-MacBook-Pro")。
    # 認証には使わない（認証は ssh.identityFiles."github-auth.pub" 側）
    signingKeyText = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPxuyd4whYtHsAZC4ijHnXKNTepukE6sp1mMDECR+kmQ git-signing@Kurichi-MacBook-Pro";
    # --vault-name は agent が読み込む鍵全体を絞り込む。SSH 鍵はすべて Personal vault に
    # あることを `pass-cli item list <vault> --filter-type ssh-key` で確認済み。
    signingVaultName = "Personal";
    gpgSign = true;
  };

  # Proton 専用ソケットが落ちても署名・認証を継続できるよう、
  # macOS システム ssh-agent にも鍵を投入する（秘密鍵がログインセッション中常駐する）
  loadKeysIntoSystemAgent = true;

  ssh = {
    includes = [ "~/.orbstack/ssh/config" ];

    identityFiles = {
      # GitHub 認証専用の Proton Pass 鍵。署名には使わない（署名は
      # git.signingKeyText -> ~/.ssh/git-signing.pub を使う）
      "github-auth.pub" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyXCW68C7NXKIKY/ZPvjcDYSxTLQM4XDQ/BdkULrMEh GitHub - Kurichi-MacBook-Pro";
    };

    matchBlocks = {
      github = {
        host = "github github.com";
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github-auth.pub";
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

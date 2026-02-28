{
  username = "kurichi";
  hostname = "Kurichi-MacBook-Pro";

  git = {
    userName = "Kurichi";
    userEmail = "me@kurichi.dev";
    signingKey = "/Users/kurichi/.ssh/github.pub";
    gpgSignProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    gpgSign = true;
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
      "onedrive"
      "orbstack"
      "postman-agent"
      "proton-mail"
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

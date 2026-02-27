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
      "discord"
      "google-drive"
      "orbstack"
      "postman-agent"
      "slack"
      "steam"
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

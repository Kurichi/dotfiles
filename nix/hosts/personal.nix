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
      "discord"
      "google-drive"
      "steam"
    ];
    masApps = {
      LINE = 539883307;
    };
  };

  packages = p: with p; [];
}

{
  username = "s30264";
  hostname = "CA-20036999";

  git = {
    userName = "Yuya Kurihara";
    userEmail = "kurihara_yuya@cyberagent.co.jp";
    signingKeyText = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhmZRh1V62B0ijzOjDgjzOOdWfauf3+6FqEd15rIi3p git-signing";
    signingVaultName = "Personal";
    gpgSign = true;
  };

  sshAuthSock = "/Users/s30264/.ssh/proton-pass-agent.sock";

  homebrew = {
    casks = [
      "alt-tab"
      "datagrip"
      "notion-calendar"
      "rancher"
      "slack"
    ];
    masApps = {};
  };

  packages = p: with p; [];
}

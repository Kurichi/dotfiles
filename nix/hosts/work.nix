{
  username = "s30264";
  hostname = "CA-20036999";

  git = {
    userName = "Yuya Kurihara";
    userEmail = "kurihara_yuya@cyberagent.co.jp";
    signingKey = "/Users/s30264/.ssh/id_ed25519.pub";
    gpgSign = true;
  };

  sshAuthSock = "/Users/s30264/.bitwarden-ssh-agent.sock";

  homebrew = {
    casks = [
      "bitwarden"
      "datagrip"
      "rancher"
    ];
    masApps = {};
  };

  packages = p: with p; [
    awscli2
    ssm-session-manager-plugin
  ];
}

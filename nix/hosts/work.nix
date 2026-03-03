{
  username = "s30264";
  hostname = "CA-20036999";

  git = {
    userName = "Yuya Kurihara";
    userEmail = "kurihara_yuya@cyberagent.co.jp";
    gpgSign = false;
  };

  homebrew = {
    casks = [
      "bitwarden"
      "datagrip"
    ];
    masApps = {};
  };

  packages = p: with p; [
    awscli2
    ssm-session-manager-plugin
  ];
}

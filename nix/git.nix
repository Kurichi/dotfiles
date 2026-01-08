_: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      color.ui = "auto";
      commit = {
        gpgsign = true;
        verbose = true;
      };
      core = {
        autocrlf = "input";
        commentChar = ";";
        editor = "nvim";
        ignorecase = false;
        pager = "LESSCHARSET=utf-8 less";
        quotepath = false;
        safecrlf = true;
      };
      credential.helper = "store";
      diff = {
        algorithm = "histogram";
        compactionHeuristic = true;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      gpg = {
        format = "ssh";
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      user.signingkey = "~/.ssh/github.pub";
    };
    ignores = [
      ".DS_Store"
      ".direnv/"
      ".env"
      "node_modules/"
    ];
  };
}

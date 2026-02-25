_: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      color.ui = "auto";
      commit = {
        gpgsign = false;
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
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      ghq.root = "~/repos";
    };
    ignores = [
      ".DS_Store"
      ".direnv/"
      ".env"
      ".kurichi/"
      "node_modules/"
      ".idea"
      ".vscode"
      ".claude/settings.local.json"
    ];
  };
}

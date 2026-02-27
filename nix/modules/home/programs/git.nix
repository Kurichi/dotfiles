{ profile, username, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = profile.git.userName;
      user.email = profile.git.userEmail;
      color.ui = "auto";
      commit = {
        gpgsign = profile.git.gpgSign or true;
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
        ssh.program = profile.git.gpgSignProgram or "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      user.signingkey = profile.git.signingKey or "/Users/${username}/.ssh/github.pub";
      ghq.root = "~/repos";
      wt.copyignored = true;
    };
    ignores = [
      ".wt/"
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

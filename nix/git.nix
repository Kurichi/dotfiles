{ lib, profile, ... }:
let
  useSigning = profile.git.signingKey != null;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = lib.mkIf (profile.git.email != null) profile.git.email;
    settings = {
      color.ui = "auto";
      commit = {
        gpgsign = useSigning;
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
      } // lib.optionalAttrs (profile.passwordManager == "1password") {
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      user = lib.optionalAttrs useSigning {
        signingkey = profile.git.signingKey;
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

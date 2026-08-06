{ lib, pkgs, profile, username, ... }:
let
  protonPassSigningSock = "/Users/${username}/.ssh/proton-pass-agent.sock";
  hasManagedSigningKey = profile.git ? signingKeyText;
  signingKeyPath =
    if hasManagedSigningKey
    then "/Users/${username}/.ssh/git-signing.pub"
    else profile.git.signingKey or "/Users/${username}/.ssh/github.pub";
  fallbackSshSignProgram = profile.git.gpgSignProgram or "${pkgs.openssh}/bin/ssh-keygen";
  allowedSignersPath = "/Users/${username}/.config/git/allowed_signers";
  # `<type> <base64>` だけに正規化する。コメント欄が付いたままだと突き合わせに失敗しうる
  signingKeyNormalized =
    if hasManagedSigningKey
    then builtins.concatStringsSep " "
      (lib.take 2 (lib.splitString " " profile.git.signingKeyText))
    else null;
  protonPassSshSign = pkgs.writeShellScript "git-ssh-sign" ''
    set -eu

    probe_output="$(${pkgs.coreutils}/bin/mktemp -t proton-pass-signing.XXXXXX)"
    cleanup() {
      ${pkgs.coreutils}/bin/rm -f "$probe_output"
    }
    trap cleanup EXIT

    if [ -S '${protonPassSigningSock}' ] && [ -r '${signingKeyPath}' ]; then
      expected_key="$(${pkgs.coreutils}/bin/cut -d' ' -f1,2 '${signingKeyPath}')"
      if [ -n "$expected_key" ]; then
        (
          SSH_AUTH_SOCK='${protonPassSigningSock}' ${pkgs.openssh}/bin/ssh-add -L 2>/dev/null | \
            ${pkgs.coreutils}/bin/cut -d' ' -f1,2 > "$probe_output"
        ) &
        probe_pid=$!
        (
          ${pkgs.coreutils}/bin/sleep 2
          /bin/kill "$probe_pid" 2>/dev/null || true
        ) &
        timeout_pid=$!

        if wait "$probe_pid"; then
          /bin/kill "$timeout_pid" 2>/dev/null || true
          if ${pkgs.gnugrep}/bin/grep -Fqx "$expected_key" "$probe_output"; then
            export SSH_AUTH_SOCK='${protonPassSigningSock}'
            if ${pkgs.openssh}/bin/ssh-keygen "$@"; then
              exit 0
            fi
          fi
        else
          /bin/kill "$timeout_pid" 2>/dev/null || true
        fi
      fi
    fi

    echo "git-ssh-sign: proton-pass agent unavailable; falling back to ${fallbackSshSignProgram}" >&2
    echo "git-ssh-sign: recover with: pass-cli login && launchctl kickstart -k gui/\$(id -u)/org.nix-community.home.proton-pass-ssh-agent" >&2

    exec "${fallbackSshSignProgram}" "$@"
  '';
in {
  home.file = lib.optionalAttrs hasManagedSigningKey {
    ".ssh/git-signing.pub".text = "${profile.git.signingKeyText}\n";
    # `git log --show-signature` / `%G?` がローカルで検証できるようにする。
    # 未設定だと署名があっても常に E（検証不能）になる。
    ".config/git/allowed_signers".text =
      "${profile.git.userEmail} ${signingKeyNormalized}\n";
  };

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
        ssh = {
          program = "${protonPassSshSign}";
        } // lib.optionalAttrs hasManagedSigningKey {
          allowedSignersFile = allowedSignersPath;
        };
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      user.signingkey = signingKeyPath;
      ghq.root = "~/repos";
      wt = {
        basedir = ".wt";
        copyignored = true;
        nocopy = [ ".venv/" ];
      };
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
      ".claude/worktrees/"
    ];
  };
}

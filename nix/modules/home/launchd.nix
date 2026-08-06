{ pkgs, profile, username, ... }:
let
  homeDir = "/Users/${username}";
  protonPassSigningSock = "${homeDir}/.ssh/proton-pass-agent.sock";
  protonPassLogPath = "${homeDir}/Library/Logs/proton-pass-ssh-agent.log";
  protonPassPidPath = "${homeDir}/.ssh/proton-pass-agent.pid";
  protonPassStatePath = "${homeDir}/.local/state/proton-pass-ssh-agent.state";
  # セッション失効時、ユーザーが復旧する手順。通知・ログの両方で同じ文言を使う
  recoveryHint = "pass-cli login && launchctl kickstart -k gui/$(id -u)/org.nix-community.home.proton-pass-ssh-agent";
  vaultArg = pkgs.lib.optionalString (profile.git ? signingVaultName)
    " --vault-name ${pkgs.lib.escapeShellArg profile.git.signingVaultName}";
  # 秘密鍵を macOS システム ssh-agent にも投入するか（personal のみ）。
  # Proton 専用ソケットが落ちても署名・認証を継続させるための多重化。
  loadKeysIntoSystemAgent = profile.loadKeysIntoSystemAgent or false;
  startProtonPassSshAgent = pkgs.writeShellScript "start-proton-pass-ssh-agent" ''
    set -eu

    ${pkgs.coreutils}/bin/mkdir -p \
      "${homeDir}/.ssh" "${homeDir}/Library/Logs" "${homeDir}/.local/state"

    log() {
      echo "$(${pkgs.coreutils}/bin/date -u +%FT%TZ) $1" >>"${protonPassLogPath}"
    }

    # 健全 -> 未認証 に遷移した時だけ通知する。5 分ごとの launchd 実行で鳴り続けないように。
    notify_once() {
      previous=""
      if [ -r '${protonPassStatePath}' ]; then
        previous="$(${pkgs.coreutils}/bin/cat '${protonPassStatePath}' 2>/dev/null || true)"
      fi
      echo "$1" >'${protonPassStatePath}' 2>/dev/null || true
      if [ "$previous" != "$1" ] && [ "$1" = "unauthenticated" ]; then
        /usr/bin/osascript -e 'display notification "セッションが切れました。pass-cli login を実行してください" with title "Proton Pass SSH agent"' >/dev/null 2>&1 || true
      fi
    }

    # ssh-add -l の終了コード: 0 = 鍵あり / 1 = agent は応答するが鍵ゼロ / 2 = agent に接触できない。
    # 「非ゼロ = ソケットが死んでいる」と誤解すると、セッション失効直後の生きた agent (rc=1) を
    # stale と誤判定して稼働中のソケットを削除してしまう。
    probe_agent() {
      probe_rc_file="$(${pkgs.coreutils}/bin/mktemp -t proton-pass-probe.XXXXXX)"
      (
        # サブシェルも set -e を継承するため、`|| inner_rc=$?` で受けないと
        # ssh-add が非ゼロを返した時点で終了コードを書き出せない
        inner_rc=0
        SSH_AUTH_SOCK='${protonPassSigningSock}' \
          ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1 || inner_rc=$?
        echo "$inner_rc" >"$probe_rc_file"
      ) &
      probe_pid=$!
      (
        ${pkgs.coreutils}/bin/sleep 5
        /bin/kill "$probe_pid" 2>/dev/null || true
      ) &
      timeout_pid=$!

      wait "$probe_pid" 2>/dev/null || true
      /bin/kill "$timeout_pid" 2>/dev/null || true

      # ファイルが空 = タイムアウトで殺された = agent に接触できない (rc=2) 扱い
      rc=2
      if [ -s "$probe_rc_file" ]; then
        rc="$(${pkgs.coreutils}/bin/cat "$probe_rc_file")"
      fi
      ${pkgs.coreutils}/bin/rm -f "$probe_rc_file"
      return "$rc"
    }

    ${pkgs.lib.optionalString loadKeysIntoSystemAgent ''
      # Proton 専用ソケットには依存しない。backend から読んで $SSH_AUTH_SOCK の agent へ書くだけ。
      # exec の後ろでは実行されないため、必ず exec より前で呼ぶこと。
      load_into_system_agent() {
        ${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent load${vaultArg} \
          >>"${protonPassLogPath}" 2>&1 || true
      }
    ''}

    stop_old_agent() {
      [ -r '${protonPassPidPath}' ] || return 0
      old_pid="$(${pkgs.jq}/bin/jq -r '.pid // empty' '${protonPassPidPath}' 2>/dev/null || true)"
      [ -n "$old_pid" ] || return 0
      # PID 再利用に備えて、実際に pass-cli の agent かを確認してから kill する
      if /bin/ps -p "$old_pid" -o command= 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -q 'pass-cli ssh-agent start'; then
        /bin/kill "$old_pid" 2>/dev/null || true
        ${pkgs.coreutils}/bin/sleep 1
      fi
    }

    rc=0
    probe_agent || rc=$?

    if [ "$rc" -eq 0 ]; then
      # 健全。稼働中のソケットには絶対に触らない。
      notify_once authenticated
      ${pkgs.lib.optionalString loadKeysIntoSystemAgent "load_into_system_agent"}
      exit 0
    fi

    if ! ${pkgs.proton-pass-cli}/bin/pass-cli vault list >/dev/null 2>>"${protonPassLogPath}"; then
      log "proton-pass ssh-agent skipped: pass-cli is not ready (recover with: ${recoveryHint})"
      notify_once unauthenticated
      # KeepAlive.SuccessfulExit = false のため、非ゼロで抜けると即再起動ループになる
      exit 0
    fi

    notify_once authenticated
    stop_old_agent
    ${pkgs.coreutils}/bin/rm -f "${protonPassSigningSock}"
    ${pkgs.lib.optionalString loadKeysIntoSystemAgent "load_into_system_agent"}

    agent_args=(
      ssh-agent
      start
      --socket-path "${protonPassSigningSock}"
      --refresh-interval 3600
    )
    ${pkgs.lib.optionalString (profile.git ? signingVaultName) ''
      agent_args+=(--vault-name ${pkgs.lib.escapeShellArg profile.git.signingVaultName})
    ''}

    exec ${pkgs.proton-pass-cli}/bin/pass-cli "''${agent_args[@]}"
  '';
in {
  # Startup apps (launchd)
  launchd.enable = true;
  launchd.agents = {
    homerow = {
      enable = true;
      config = {
        ProgramArguments = [ "/Applications/Homerow.app/Contents/MacOS/Homerow" ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
    proton-pass-ssh-agent = {
      enable = true;
      config = {
        ProgramArguments = [ "${startProtonPassSshAgent}" ];
        RunAtLoad = true;
        StartInterval = 300;
        ThrottleInterval = 30;
        KeepAlive = {
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        StandardOutPath = protonPassLogPath;
        StandardErrorPath = protonPassLogPath;
      };
    };
  };
}

{ pkgs, profile, username, ... }:
let
  homeDir = "/Users/${username}";
  protonPassSigningSock = "${homeDir}/.ssh/proton-pass-agent.sock";
  protonPassLogPath = "${homeDir}/Library/Logs/proton-pass-ssh-agent.log";
  protonPassPidPath = "${homeDir}/.ssh/proton-pass-agent.pid";
  protonPassStatePath = "${homeDir}/.local/state/proton-pass-ssh-agent.state";
  protonPassLabel = "org.nix-community.home.proton-pass-ssh-agent";
  # セッション失効時、ユーザーが復旧する手順。通知・ログの両方で同じ文言を使う
  recoveryHint = "pass-cli login && launchctl kickstart -k gui/$(id -u)/${protonPassLabel}";
  vaultArg = pkgs.lib.optionalString (profile.git ? signingVaultName)
    " --vault-name ${pkgs.lib.escapeShellArg profile.git.signingVaultName}";
  # 秘密鍵を macOS システム ssh-agent にも投入するか（personal のみ）。
  # Proton 専用ソケットが落ちても署名・認証を継続させるための多重化。
  loadKeysIntoSystemAgent = profile.loadKeysIntoSystemAgent or false;

  # 両スクリプトで共有する関数群。log/notify_once/load_into_system_agent は
  # agent 本体・watchdog の双方から呼ばれるため一箇所にまとめる。
  sharedFunctions = ''
    log() {
      echo "$(${pkgs.coreutils}/bin/date -u +%FT%TZ) $1" >>"${protonPassLogPath}"
    }

    # 健全 <-> 未認証 の状態遷移時だけ通知する。ポーリングのたびに鳴り続けないように。
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

    ${pkgs.lib.optionalString loadKeysIntoSystemAgent ''
      # Proton 専用ソケットには依存しない。backend から読んで $SSH_AUTH_SOCK の agent へ書くだけ。
      load_into_system_agent() {
        ${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent load${vaultArg} \
          >>"${protonPassLogPath}" 2>&1 || true
      }
    ''}
  '';

  # agent 本体: launchd が単一インスタンスを保証するため、起動時点で socket に
  # 居るのは孤児か stale のみ。probe はせず、認証待ちの後に無条件でテイクオーバーする。
  # KeepAlive=true 前提のため、exit するパスを持たない（未認証中もスクリプト内でブロックする）。
  startProtonPassSshAgent = pkgs.writeShellScript "start-proton-pass-ssh-agent" ''
    set -eu

    ${pkgs.coreutils}/bin/mkdir -p \
      "${homeDir}/.ssh" "${homeDir}/Library/Logs" "${homeDir}/.local/state"

    ${sharedFunctions}

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

    # 認証待ち: exit せずスクリプト内でブロックする。KeepAlive=true のもとで exit すると
    # ThrottleInterval(30s) ごとの再起動ループになり vault list を叩き続けてしまうため。
    # ログは初回のみ（120秒ごとに書くと未ログイン中に大量のログ行になる）。
    waited=""
    until ${pkgs.proton-pass-cli}/bin/pass-cli vault list >/dev/null 2>>"${protonPassLogPath}"; do
      if [ -z "$waited" ]; then
        log "waiting for authentication (recover with: ${recoveryHint})"
        waited=1
      fi
      notify_once unauthenticated
      ${pkgs.coreutils}/bin/sleep 120
    done
    notify_once authenticated

    # 無条件テイクオーバー。孤児が生きた鍵を提供している可能性があるため、
    # 認証待ちの「後」に実行すること。
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

  # watchdog: 「プロセスは生きているが socket が応答しない stuck」のみを担当する短命スクリプト。
  # exec しないので launchd の StartInterval が保留され続ける問題は起きない。
  protonPassWatchdog = pkgs.writeShellScript "proton-pass-ssh-agent-watchdog" ''
    set -eu

    ${sharedFunctions}

    # 未認証中は agent 本体の待機ループに任せる。ここで probe すると
    # 5 分ごとに認証待ちループを kickstart -k で殺してしまう。
    state=""
    if [ -r '${protonPassStatePath}' ]; then
      state="$(${pkgs.coreutils}/bin/cat '${protonPassStatePath}' 2>/dev/null || true)"
    fi
    if [ "$state" = "unauthenticated" ]; then
      exit 0
    fi

    # ssh-add -l の終了コード: 0 = 鍵あり / 1 = agent は応答するが鍵ゼロ / 2 (or timeout=124) = 接触不能
    probe() {
      SSH_AUTH_SOCK='${protonPassSigningSock}' \
        ${pkgs.coreutils}/bin/timeout 10 ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
    }

    rc=0
    probe || rc=$?

    if [ "$rc" -le 1 ]; then
      if [ "$rc" -eq 0 ]; then
        ${pkgs.lib.optionalString loadKeysIntoSystemAgent "load_into_system_agent"}
      else
        # rc=1: agent は生きているが鍵ゼロ = セッション失効の可能性。ここを健全扱いすると
        # 「agent 生存 + セッション失効」が誰にも検知されず git pull が同じ症状で落ち続ける。
        if ! ${pkgs.proton-pass-cli}/bin/pass-cli vault list >/dev/null 2>>"${protonPassLogPath}"; then
          notify_once unauthenticated
        fi
      fi
      exit 0
    fi

    # 高負荷時の誤殺対策: 1 回の失敗では殺さない。5 秒空けてもう一度 probe する。
    ${pkgs.coreutils}/bin/sleep 5
    rc=0
    probe || rc=$?
    if [ "$rc" -le 1 ]; then
      exit 0
    fi

    log "watchdog: socket unresponsive after 2 probes; kickstarting agent"
    /bin/launchctl kickstart -k "gui/$(id -u)/${protonPassLabel}" || log "watchdog: kickstart failed"
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
        KeepAlive = true; # あらゆる exit（正常終了での自壊を含む）で再起動する
        ThrottleInterval = 30; # クラッシュストームの抑制。認証待ちは内部 sleep のため無関係
        ProcessType = "Background";
        StandardOutPath = protonPassLogPath;
        StandardErrorPath = protonPassLogPath;
      };
    };
    proton-pass-ssh-agent-watchdog = {
      enable = true;
      config = {
        ProgramArguments = [ "${protonPassWatchdog}" ];
        RunAtLoad = false; # ログイン直後の agent 起動と競合させない（初回発火はロード5分後）
        StartInterval = 300;
        ProcessType = "Background";
        StandardOutPath = protonPassLogPath;
        StandardErrorPath = protonPassLogPath;
      };
    };
  };
}

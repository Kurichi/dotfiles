{ pkgs, profile, username, ... }:
let
  homeDir = "/Users/${username}";
  protonPassSigningSock = "${homeDir}/.ssh/proton-pass-agent.sock";
  protonPassLogPath = "${homeDir}/Library/Logs/proton-pass-ssh-agent.log";
  startProtonPassSshAgent = pkgs.writeShellScript "start-proton-pass-ssh-agent" ''
    set -eu

    ${pkgs.coreutils}/bin/mkdir -p "${homeDir}/.ssh" "${homeDir}/Library/Logs"

    if ! ${pkgs.proton-pass-cli}/bin/pass-cli vault list >/dev/null 2>>"${protonPassLogPath}"; then
      echo "$(${pkgs.coreutils}/bin/date -u +%FT%TZ) proton-pass ssh-agent skipped: pass-cli is not ready" >>"${protonPassLogPath}"
      exit 0
    fi

    ${pkgs.coreutils}/bin/rm -f "${protonPassSigningSock}"

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

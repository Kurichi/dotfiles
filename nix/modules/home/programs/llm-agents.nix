{ config, pkgs, lib, username, ... }:

let
  claudeNixSettings = pkgs.writeText "claude-nix-settings.json" (builtins.toJSON {
    trustedDirectories = [ "/Users/${username}/repos" ];
    respectGitignore = false;
    cleanupPeriodDays = 90;
    env = {
      EDITOR = "nvim";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      # AskUserQuestion の60秒無応答で自動継続してしまう挙動(AFK auto-continue)の抑制
      # 0/負数は即時発火する既知のバグがあるため int32 最大値を指定
      CLAUDE_AFK_TIMEOUT_MS = "2147483647";
      CLAUDE_AFK_COUNTDOWN_MS = "2147483647";
      # work の managed policy が DISABLE_TELEMETRY=1 を設定しており feature flag
      # (tengu_sage_compass2) を受信できず /advisor が無効化されるため、明示的に有効化する
      CLAUDE_CODE_ENABLE_EXPERIMENTAL_ADVISOR_TOOL = "1";
    };
    permissions = {
      allow = [
        "Bash(fd:*)" "Bash(rg:*)" "Bash(eza:*)"
        "WebSearch"
      ];
      deny = [ "Bash(git reset --hard:*)" ];
      defaultMode = "auto";
    };
    # 使わない claude.ai コネクタを無効化（名前は "claude.ai <display_name>" で verbatim 比較）
    deniedMcpServers = map (name: { serverName = "claude.ai ${name}"; }) [
      "Asana"
      "Atlassian"
      "Box"
      "Canva"
      "HubSpot"
      "Intercom"
      "Microsoft 365"
      "Notion"
      "bugmap"
      "monday.com"
    ] ++ [
      # Datadog は v1 (https://mcp.datadoghq.com/v1/mcp) を残し、unstable 版を止める。
      # 同名コネクタは "claude.ai Datadog (2)" のように連番になり番号が変わりうるため URL で指定する
      { serverUrl = "https://mcp.datadoghq.com/api/unstable/*"; }
    ];
    sandbox = {
      # codex plugin の companion はサンドボックス内だと ~/.config/claude/plugins/data に
      # ジョブ用ディレクトリを作れず EPERM で止まるため、最初からサンドボックス外で実行する
      excludedCommands = [ "node */openai-codex/codex/*/scripts/codex-companion.mjs*" ];
    };
    model = "opus";
    effortLevel = "xhigh";
    hooks = {
      PreToolUse = [{ matcher = "Bash"; hooks = [{ type = "command"; command = "$HOME/.config/claude/hooks/guard-worktree.sh"; }]; }];
      Notification = [{ hooks = [{ type = "command"; command = "$HOME/.config/claude/hooks/notify.sh"; }]; }];
      Stop = [{ hooks = [{ type = "command"; command = "$HOME/.config/claude/hooks/notify.sh 'タスク完了'"; }]; }];
    };
    statusLine = { type = "command"; command = "bunx -y ccstatusline@latest"; padding = 0; };
    outputStyle = "Explanatory";
    language = "Japanese";
    spinnerVerbs = {
      mode = "replace";
      verbs = [ "うーむ" "う〜〜〜む" "脳みそフル回転中" "考え中" "うるとらしんきんぐ" "頭がオーバーヒート" ];
    };
  });

  claudeMergeScript = pkgs.writeText "claude-merge.jq" ''
    def merge_arrays: (.[0] + .[1]) | unique;

    .[0] as $existing |
    .[1] as $nix |

    $existing * $nix |

    .permissions.allow = ([$existing.permissions.allow // [], $nix.permissions.allow // []] | merge_arrays) |
    .permissions.deny = ([$existing.permissions.deny // [], $nix.permissions.deny // []] | merge_arrays) |
    .trustedDirectories = ([$existing.trustedDirectories // [], $nix.trustedDirectories // []] | merge_arrays) |
    .enabledPlugins = ($existing.enabledPlugins // {})
  '';
in
{
  # Claude Code configuration
  home.file.".config/claude/CLAUDE.md".source = ../../../../config/claude/CLAUDE.md;
  home.file.".config/claude/skills".source = ../../../../config/claude/skills;
  home.file.".config/claude/hooks".source = ../../../../config/claude/hooks;

  # Gemini CLI configuration
  home.file.".config/.gemini/GEMINI.md".source = ../../../../config/gemini/GEMINI.md;

  # Activation script: merge Nix-managed settings with existing settings
  home.activation.mergeLlmAgentConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Claude Code settings.json merge (temp file + mv for atomic update)
    CLAUDE_SETTINGS="$HOME/.config/claude/settings.json"
    CLAUDE_NIX_SETTINGS="${claudeNixSettings}"
    run mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
    if [ -f "$CLAUDE_SETTINGS" ]; then
      run chmod u+w "$CLAUDE_SETTINGS"
      CLAUDE_TMP="$(mktemp)"
      run ${pkgs.jq}/bin/jq -s -f ${claudeMergeScript} "$CLAUDE_SETTINGS" "$CLAUDE_NIX_SETTINGS" > "$CLAUDE_TMP"
      run mv "$CLAUDE_TMP" "$CLAUDE_SETTINGS"
    else
      run cp "$CLAUDE_NIX_SETTINGS" "$CLAUDE_SETTINGS"
    fi
    run chmod u+w "$CLAUDE_SETTINGS"

    # Gemini CLI settings.json merge
    GEMINI_SETTINGS="$HOME/.config/.gemini/settings.json"
    GEMINI_NIX_SETTINGS="${../../../../config/gemini/settings.json}"
    run mkdir -p "$(dirname "$GEMINI_SETTINGS")"
    if [ -f "$GEMINI_SETTINGS" ]; then
      run chmod u+w "$GEMINI_SETTINGS"
      GEMINI_TMP="$(mktemp)"
      run ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$GEMINI_SETTINGS" "$GEMINI_NIX_SETTINGS" > "$GEMINI_TMP"
      run mv "$GEMINI_TMP" "$GEMINI_SETTINGS"
    else
      run cp "$GEMINI_NIX_SETTINGS" "$GEMINI_SETTINGS"
    fi
    run chmod u+w "$GEMINI_SETTINGS"
  '';
}

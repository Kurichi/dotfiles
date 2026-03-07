{ config, pkgs, lib, username, ... }:

let
  claudeNixSettings = pkgs.writeText "claude-nix-settings.json" (builtins.toJSON {
    trustedDirectories = [ "/Users/${username}/repos" ];
    respectGitignore = false;
    cleanupPeriodDays = 90;
    env = {
      EDITOR = "nvim";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    };
    permissions = {
      allow = [
        "Bash(fd:*)" "Bash(rg:*)" "Bash(eza:*)"
        "mcp__gopls__*" "mcp__deepwiki__*" "WebSearch"
      ];
      deny = [ "Bash(git reset --hard:*)" ];
      defaultMode = "plan";
    };
    model = "opus[1m]";
    reasoningEffort = "medium";
    hooks = {
      PreToolUse = [{ matcher = "Bash"; hooks = [{ type = "command"; command = "$HOME/.config/claude/hooks/guard-worktree.sh"; }]; }];
      Notification = [{ hooks = [{ type = "command"; command = "afplay /System/Library/Sounds/Glass.aiff"; }]; }];
      Stop = [{ hooks = [{ type = "command"; command = "afplay /System/Library/Sounds/Funk.aiff"; }]; }];
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

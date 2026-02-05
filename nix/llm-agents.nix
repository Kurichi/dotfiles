{ config, pkgs, lib, ... }:

let
  # Claude Code 設定マージ用 jq スクリプト
  claudeMergeScript = pkgs.writeText "claude-merge.jq" ''
    # 既存設定（$existing）と Nix 設定（$nix）をスマートマージ
    # - 配列: 既存 + Nix（重複除去）
    # - オブジェクト: Nix が優先だが、既存のキーも保持
    # - permissions.allow/deny: 配列マージ

    def merge_arrays: (.[0] + .[1]) | unique;

    # ベースは既存設定
    .[0] as $existing |
    .[1] as $nix |

    # 既存設定をベースに Nix 設定をマージ
    $existing * $nix |

    # permissions は配列マージ（既存 + Nix）
    .permissions.allow = ([$existing.permissions.allow // [], $nix.permissions.allow // []] | merge_arrays) |
    .permissions.deny = ([$existing.permissions.deny // [], $nix.permissions.deny // []] | merge_arrays) |

    # trustedDirectories は配列マージ（既存 + Nix）
    .trustedDirectories = ([$existing.trustedDirectories // [], $nix.trustedDirectories // []] | merge_arrays) |

    # enabledPlugins は既存を保持（TODO: 将来的に Nix 管理）
    .enabledPlugins = ($existing.enabledPlugins // {})
  '';
in
{
  # Claude Code configuration
  home.file.".config/claude/CLAUDE.md".source = ../config/claude/CLAUDE.md;
  home.file.".config/claude/skills".source = ../config/claude/skills;
  home.file.".config/claude/commands".source = ../config/claude/commands;

  # Gemini CLI configuration
  home.file.".config/.gemini/GEMINI.md".source = ../config/gemini/GEMINI.md;

  # Activation script: Nix管理設定と既存設定をスマートマージ
  home.activation.mergeLlmAgentConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Claude Code settings.json マージ
    CLAUDE_SETTINGS="$HOME/.config/claude/settings.json"
    CLAUDE_NIX_SETTINGS="${../config/claude/settings.json}"
    if [ -f "$CLAUDE_SETTINGS" ]; then
      # スマートマージ: 配列は結合、オブジェクトはNix優先
      run ${pkgs.jq}/bin/jq -s -f ${claudeMergeScript} "$CLAUDE_SETTINGS" "$CLAUDE_NIX_SETTINGS" | \
        run ${pkgs.moreutils}/bin/sponge "$CLAUDE_SETTINGS"
    else
      run cp "$CLAUDE_NIX_SETTINGS" "$CLAUDE_SETTINGS"
    fi

    # Gemini CLI settings.json マージ（シンプルマージ）
    GEMINI_SETTINGS="$HOME/.config/.gemini/settings.json"
    GEMINI_NIX_SETTINGS="${../config/gemini/settings.json}"
    run mkdir -p "$(dirname "$GEMINI_SETTINGS")"
    if [ -f "$GEMINI_SETTINGS" ]; then
      # 既存設定に Nix 設定をマージ（Nix優先、既存の認証情報は保持）
      run chmod u+w "$GEMINI_SETTINGS"
      run ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$GEMINI_SETTINGS" "$GEMINI_NIX_SETTINGS" | \
        run ${pkgs.moreutils}/bin/sponge "$GEMINI_SETTINGS"
    else
      run cp "$GEMINI_NIX_SETTINGS" "$GEMINI_SETTINGS"
      run chmod u+w "$GEMINI_SETTINGS"
    fi
  '';
}

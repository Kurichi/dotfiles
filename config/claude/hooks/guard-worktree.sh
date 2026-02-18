#!/usr/bin/env bash
set -euo pipefail

# === Fail-closed: パース失敗時は deny ===
INPUT=$(cat) || { echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"hook: stdin read failed"}}'; exit 0; }
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty') || { echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"hook: jq parse failed"}}'; exit 0; }
CWD=$(echo "$INPUT" | jq -r '.cwd // empty') || CWD=""

# CWD が空 or 存在しないならスルー（Git 外の作業）
[ -n "$CWD" ] && [ -d "$CWD" ] || exit 0

# Git worktree 外ならスルー
WORKTREE_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null) || exit 0

# main worktree のパスを取得（worktree list の先頭行）
MAIN_WORKTREE=$(git -C "$CWD" worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //') || exit 0

# 現在が main worktree ならガード不要
if [ "$WORKTREE_ROOT" = "$MAIN_WORKTREE" ]; then
  exit 0
fi

# === linked worktree 上では cd / pushd / popd を全面禁止 ===
if echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|\|)(cd|pushd|popd)\s'; then
  cat <<HOOKJSON
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "worktree 内ではディレクトリ移動（cd/pushd/popd）は禁止されています。現在の worktree ($WORKTREE_ROOT) 内で絶対パスを使用してください。"
  }
}
HOOKJSON
  exit 0
fi

# === main worktree パスへの参照もブロック（git -C <main> 等） ===
if echo "$COMMAND" | grep -qF "$MAIN_WORKTREE"; then
  cat <<HOOKJSON
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "main worktree ($MAIN_WORKTREE) への参照は禁止されています。現在の worktree ($WORKTREE_ROOT) 内で作業してください。"
  }
}
HOOKJSON
  exit 0
fi

exit 0

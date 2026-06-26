#!/usr/bin/env bash
set -euo pipefail

# Claude Code Notification hook
# permission 要求 or 60 秒アイドルで発火するため、macOS 通知センターに表示する。

INPUT=$(cat) || INPUT='{}'
MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // empty' 2>/dev/null || true)
[ -z "$MESSAGE" ] && MESSAGE="入力を待っています"

CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
SUBTITLE=""
if [ -n "$CWD" ]; then
  SUBTITLE=$(basename "$CWD")
fi

escape_for_osascript() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

TITLE_ESC=$(escape_for_osascript "Claude Code")
MESSAGE_ESC=$(escape_for_osascript "$MESSAGE")
SUBTITLE_ESC=$(escape_for_osascript "$SUBTITLE")

if [ -n "$SUBTITLE_ESC" ]; then
  SCRIPT="display notification \"$MESSAGE_ESC\" with title \"$TITLE_ESC\" subtitle \"$SUBTITLE_ESC\" sound name \"Glass\""
else
  SCRIPT="display notification \"$MESSAGE_ESC\" with title \"$TITLE_ESC\" sound name \"Glass\""
fi

osascript -e "$SCRIPT" >/dev/null 2>&1 || true

exit 0

#!/usr/bin/env bash
set -euo pipefail

# Claude Code Notification/Stop hook
# stdin の JSON から message (無ければ引数のデフォルト値) を取り出し、
# ターミナルタイトルにセットしてから BEL を送る。
# WezTerm 側の wezterm.on("bell", ...) がこれを拾って toast 通知を表示する。

DEFAULT_MESSAGE="${1:-入力を待っています}"

INPUT=$(cat) || INPUT='{}'
MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // empty' 2>/dev/null || true)
[ -z "$MESSAGE" ] && MESSAGE="$DEFAULT_MESSAGE"

CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
if [ -n "$CWD" ]; then
  MESSAGE="$(basename "$CWD"): $MESSAGE"
fi

# 端末エスケープシーケンスインジェクション対策: 制御文字を除去(改行等は単語の連結を防ぐためスペースに置換)
sanitize() {
  printf '%s' "$1" | tr '\000-\037\177' ' ' | tr -s ' '
}
MESSAGE=$(sanitize "$MESSAGE")

# Claude Code が hook の stdout をパイプで捕捉する可能性があるため、
# 実際の端末 (/dev/tty) に直接書き込む。
# claude -p や scheduled routine 等、制御端末を持たない非対話実行では /dev/tty が使えないため、
# その場合は macOS 通知センターにフォールバックする。
if ! { printf '\033]0;%s\007\a' "$MESSAGE" >/dev/tty; } 2>/dev/null; then
  ESCAPED=$(printf '%s' "$MESSAGE" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
  osascript -e "display notification \"$ESCAPED\" with title \"Claude Code\"" >/dev/null 2>&1 || true
fi

exit 0

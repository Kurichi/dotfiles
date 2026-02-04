#!/usr/bin/env bash
set -euo pipefail

# Codex セッションに追加メッセージを送信（tmux / WezTerm 両対応）
# Usage: send_to_codex.sh <output_dir> <message>

# ヘルパーライブラリを読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pane_utils.sh"

OUTPUT_DIR="$1"
MESSAGE="$2"

CODEX_PANE_ID=$(cat "$OUTPUT_DIR/codex_pane_id")

# 既存のペインが存在するか確認
if ! pane_exists "$CODEX_PANE_ID"; then
    echo "Error: Codex pane $CODEX_PANE_ID not found"
    exit 1
fi

# メッセージを Codex のインタラクティブセッションに直接入力
# 改行を空白に置換してから送信
SANITIZED_MESSAGE=$(printf '%s' "$MESSAGE" | tr '\n' ' ')
pane_send_text "$CODEX_PANE_ID" "$SANITIZED_MESSAGE"

# 入力がバッファに反映されるまで少し待機
sleep 0.1

# Enter を送信
pane_send_enter "$CODEX_PANE_ID"

echo "Message sent to Codex session"

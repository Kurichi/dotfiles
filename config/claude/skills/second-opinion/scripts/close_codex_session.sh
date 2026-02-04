#!/usr/bin/env bash
set -euo pipefail

# Codex レビューセッションを終了（tmux / WezTerm 両対応）
# Usage: close_codex_session.sh <output_dir>

# ヘルパーライブラリを読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pane_utils.sh"

OUTPUT_DIR="$1"

CODEX_PANE_ID=$(cat "$OUTPUT_DIR/codex_pane_id" 2>/dev/null || echo "")

if [ -z "$CODEX_PANE_ID" ]; then
    echo "No Codex pane ID found"
    exit 0
fi

# ペインが存在するか確認
if pane_exists "$CODEX_PANE_ID"; then
    # Codex プロセスを終了
    pane_send_interrupt "$CODEX_PANE_ID"
    pane_send_enter "$CODEX_PANE_ID"
    sleep 1

    # ペインを閉じる
    pane_kill "$CODEX_PANE_ID"
    echo "Codex pane $CODEX_PANE_ID closed"
else
    echo "Codex pane $CODEX_PANE_ID not found (may already be closed)"
fi

# クリーンアップ（オプション）
# rm -rf "$OUTPUT_DIR"

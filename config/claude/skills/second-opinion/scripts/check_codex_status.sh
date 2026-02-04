#!/usr/bin/env bash
set -euo pipefail

# Codex の返答をチェック（tmux / WezTerm 両対応）
# Usage: check_codex_status.sh <output_dir>
#
# ステータス:
#   waiting    - 出力に変化なし
#   new_output - 出力に変化あり（2行目以降に内容）
#   pane_closed - ペインが閉じられた

# ヘルパーライブラリを読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pane_utils.sh"

OUTPUT_DIR="$1"
CODEX_PANE_ID_FILE="$OUTPUT_DIR/codex_pane_id"
LAST_HASH_FILE="$OUTPUT_DIR/last_hash"
LAST_OUTPUT_FILE="$OUTPUT_DIR/last_output"

# Codex ペイン ID を取得
if [ ! -f "$CODEX_PANE_ID_FILE" ]; then
    echo "waiting"
    exit 0
fi

CODEX_PANE_ID=$(cat "$CODEX_PANE_ID_FILE")

# ペインが存在するか確認
if ! pane_exists "$CODEX_PANE_ID"; then
    echo "pane_closed"
    exit 0
fi

# 現在のペイン内容をキャプチャ
CURRENT_OUTPUT=$(pane_get_text "$CODEX_PANE_ID")

# ハッシュを計算（高速な比較のため）
# macOS と Linux の両方に対応
if command -v md5sum &>/dev/null; then
    CURRENT_HASH=$(echo "$CURRENT_OUTPUT" | md5sum | cut -d' ' -f1)
else
    CURRENT_HASH=$(echo "$CURRENT_OUTPUT" | md5 -q)
fi

# 初回実行時
if [ ! -f "$LAST_HASH_FILE" ]; then
    echo "$CURRENT_HASH" > "$LAST_HASH_FILE"
    echo "$CURRENT_OUTPUT" > "$LAST_OUTPUT_FILE"
    echo "waiting"
    exit 0
fi

LAST_HASH=$(cat "$LAST_HASH_FILE")

if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
    # 出力に変化あり
    echo "$CURRENT_HASH" > "$LAST_HASH_FILE"
    echo "$CURRENT_OUTPUT" > "$LAST_OUTPUT_FILE"
    echo "new_output"
    echo "$CURRENT_OUTPUT"
else
    # 出力に変化なし
    echo "waiting"
fi

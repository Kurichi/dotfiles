#!/usr/bin/env bash
set -euo pipefail

# Codex レビューセッションをペインで開始（tmux / WezTerm 両対応）
# Usage: start_codex_review.sh <prompt> <output_dir>

# ヘルパーライブラリを読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pane_utils.sh"

PROMPT="$1"
OUTPUT_DIR="$2"
SESSION_ID="${3:-codex-review-$$}"

# 現在の作業ディレクトリを保存（Claude Codeが実行中のディレクトリ）
WORKING_DIR="$(pwd)"

# 出力ディレクトリを作成
mkdir -p "$OUTPUT_DIR"

# セッション情報を保存
echo "$SESSION_ID" > "$OUTPUT_DIR/session_id"
echo "$WORKING_DIR" > "$OUTPUT_DIR/working_dir"

# ペインバックエンドを確認
BACKEND=$(pane_detect_backend)
if [ "$BACKEND" = "none" ]; then
    echo "Error: Neither tmux nor WezTerm detected"
    echo "Please run Claude Code inside a tmux session or WezTerm"
    exit 1
fi
echo "$BACKEND" > "$OUTPUT_DIR/pane_backend"

# 現在のペインを取得
CURRENT_PANE=$(pane_get_current_id)
echo "$CURRENT_PANE" > "$OUTPUT_DIR/claude_pane_id"

# プロンプトをファイルに保存（改行を含む場合でも安全に渡すため）
PROMPT_FILE="$OUTPUT_DIR/prompt.txt"
printf '%s' "$PROMPT" > "$PROMPT_FILE"

# 一時スクリプトファイルを作成（クォート問題を回避）
RUNNER_SCRIPT="$OUTPUT_DIR/run_codex.sh"
cat > "$RUNNER_SCRIPT" << 'SCRIPT_EOF'
#!/usr/bin/env bash
WORKING_DIR="$1"
PROMPT_FILE="$2"

cd "$WORKING_DIR"

# プロンプトファイルから読み取り（改行を空白に置換）
PROMPT=$(tr '\n' ' ' < "$PROMPT_FILE")

codex "$PROMPT"
echo ""
echo "--- Codex session ended. Press Enter to close ---"
read
SCRIPT_EOF
chmod +x "$RUNNER_SCRIPT"

# 横分割で新しいペインを作成し、スクリプトを実行
NEW_PANE=$(pane_split_and_run "$RUNNER_SCRIPT" "$WORKING_DIR" "$PROMPT_FILE")
echo "$NEW_PANE" > "$OUTPUT_DIR/codex_pane_id"

# Codex の出力を記録するためのログファイル
LOG_FILE="$OUTPUT_DIR/codex_output.log"
CONVERSATION_ID_FILE="$OUTPUT_DIR/conversation_id"

# Claude Code 側のペインを選択（両方見える状態を維持）
pane_select "$CURRENT_PANE"

# Codex が起動するまで少し待つ
sleep 3

# 初期の出力をキャプチャしてログファイルに保存
pane_get_text "$NEW_PANE" > "$LOG_FILE"

# Conversation ID は後続のやり取りで必要な場合のみ取得
# （現在のcodexは会話IDを明示的に表示しないため、ペインIDで管理）
echo "managed-by-pane" > "$CONVERSATION_ID_FILE"

echo "Codex review session started in pane $NEW_PANE (backend: $BACKEND)"
echo "Working directory: $WORKING_DIR"
echo "Session ID: $SESSION_ID"
echo "Output: $LOG_FILE"

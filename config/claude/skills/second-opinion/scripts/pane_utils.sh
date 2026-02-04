#!/usr/bin/env bash
# ペイン操作の抽象化層（tmux / WezTerm 両対応）
#
# このライブラリは tmux と WezTerm のペイン操作を統一的に扱うための
# ヘルパー関数を提供します。
#
# Usage: source pane_utils.sh

# バックエンド検出
# 戻り値: "tmux", "wezterm", または "none"
pane_detect_backend() {
    if [ -n "${TMUX:-}" ]; then
        echo "tmux"
    elif [ -n "${WEZTERM_PANE:-}" ]; then
        echo "wezterm"
    else
        echo "none"
    fi
}

# ペインが存在するか確認
# 引数: $1 - ペインID
# 戻り値: 0 (存在する) または 1 (存在しない)
pane_exists() {
    local pane_id="$1"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux list-panes -a -F '#{pane_id}' | grep -q "^$pane_id$"
            ;;
        wezterm)
            wezterm cli list --format json | jq -e ".[] | select(.pane_id == $pane_id)" > /dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# 現在のペインIDを取得
# 戻り値: ペインID（標準出力）
pane_get_current_id() {
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux display-message -p '#{pane_id}'
            ;;
        wezterm)
            echo "$WEZTERM_PANE"
            ;;
        *)
            return 1
            ;;
    esac
}

# ペインを右側に分割して新しいペインでコマンドを実行
# 引数: $1 - 実行するコマンド, $2... - コマンドの引数
# 戻り値: 新しいペインID（標準出力）
pane_split_and_run() {
    local command="$1"
    shift
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux split-window -h -P -F '#{pane_id}' "$command" "$@"
            ;;
        wezterm)
            wezterm cli split-pane --right -- "$command" "$@"
            ;;
        *)
            return 1
            ;;
    esac
}

# ペインの内容を取得（スクロールバック含む）
# 引数: $1 - ペインID
# 戻り値: ペインの内容（標準出力）
pane_get_text() {
    local pane_id="$1"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux capture-pane -t "$pane_id" -p -S -
            ;;
        wezterm)
            wezterm cli get-text --pane-id "$pane_id" --start-line -10000
            ;;
        *)
            return 1
            ;;
    esac
}

# ペインにテキストを送信（改行なし）
# 引数: $1 - ペインID, $2 - 送信するテキスト
pane_send_text() {
    local pane_id="$1"
    local text="$2"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux send-keys -t "$pane_id" -l "$text"
            ;;
        wezterm)
            # --no-paste: bracketed paste mode を無効化し、直接入力として送信
            wezterm cli send-text --no-paste --pane-id "$pane_id" -- "$text"
            ;;
        *)
            return 1
            ;;
    esac
}

# ペインに Enter を送信
# 引数: $1 - ペインID
pane_send_enter() {
    local pane_id="$1"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux send-keys -t "$pane_id" Enter
            ;;
        wezterm)
            # --no-paste: CR (carriage return) を Enter キーとして送信
            # 注: ターミナルでは \n (LF) ではなく \r (CR) が Enter に相当
            printf '\r' | wezterm cli send-text --no-paste --pane-id "$pane_id"
            ;;
        *)
            return 1
            ;;
    esac
}

# ペインに Ctrl+C を送信（プロセス中断）
# 引数: $1 - ペインID
pane_send_interrupt() {
    local pane_id="$1"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux send-keys -t "$pane_id" C-c
            ;;
        wezterm)
            # --no-paste: Ctrl+C を制御文字として直接送信
            wezterm cli send-text --no-paste --pane-id "$pane_id" $'\x03'
            ;;
        *)
            return 1
            ;;
    esac
}

# ペインを終了
# 引数: $1 - ペインID
pane_kill() {
    local pane_id="$1"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux kill-pane -t "$pane_id"
            ;;
        wezterm)
            wezterm cli kill-pane --pane-id "$pane_id"
            ;;
        *)
            return 1
            ;;
    esac
}

# 指定したペインを選択（フォーカス）
# 引数: $1 - ペインID
pane_select() {
    local pane_id="$1"
    local backend
    backend=$(pane_detect_backend)

    case "$backend" in
        tmux)
            tmux select-pane -t "$pane_id"
            ;;
        wezterm)
            wezterm cli activate-pane --pane-id "$pane_id"
            ;;
        *)
            return 1
            ;;
    esac
}

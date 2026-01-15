#!/bin/bash
# Claude Code Hook: コマンドバイパス実行
#
# 使い方:
#   $ command     - 即時実行、Claude にはブロック（ラグなし）
#   $$ command    - 即時実行、結果を Claude のコンテキストに追加

# 標準入力からJSONを読み取り
INPUT=$(cat)

# プロンプトを抽出（jqを使用）
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')

# $$で始まるか（コンテキスト付きモード）
if [[ "$PROMPT" == \$\$* ]]; then
    # $$を除去してコマンドを取得
    COMMAND="${PROMPT#\$\$}"
    COMMAND="${COMMAND#"${COMMAND%%[![:space:]]*}"}"

    if [[ -n "$COMMAND" ]]; then
        cd "$CWD" 2>/dev/null || true
        OUTPUT=$(eval "$COMMAND" 2>&1)
        EXIT_CODE=$?

        # コンテキストとして結果を出力（ブロックしない）
        echo "<command-executed>"
        echo "$ $COMMAND"
        if [[ -n "$OUTPUT" ]]; then
            echo "$OUTPUT"
        fi
        if [[ $EXIT_CODE -ne 0 ]]; then
            echo "(exit code: $EXIT_CODE)"
        fi
        echo "</command-executed>"
        echo ""
        echo "上記のコマンドは既に実行済みです。結果を確認して必要に応じて対応してください。"
        exit 0
    fi
fi

# $で始まるか（ブロックモード）
if [[ "$PROMPT" == \$* ]]; then
    # $を除去してコマンドを取得
    COMMAND="${PROMPT#\$}"
    COMMAND="${COMMAND#"${COMMAND%%[![:space:]]*}"}"

    if [[ -n "$COMMAND" ]]; then
        cd "$CWD" 2>/dev/null || true
        OUTPUT=$(eval "$COMMAND" 2>&1)
        EXIT_CODE=$?

        # 結果をJSON形式で出力（ブロック）
        if [[ $EXIT_CODE -eq 0 ]]; then
            RESULT_MSG="$ $COMMAND"
            if [[ -n "$OUTPUT" ]]; then
                RESULT_MSG="$RESULT_MSG
$OUTPUT"
            fi
        else
            RESULT_MSG="$ $COMMAND
$OUTPUT
(exit code: $EXIT_CODE)"
        fi

        # JSONエスケープ
        ESCAPED_MSG=$(echo "$RESULT_MSG" | jq -Rs '.')

        # ブロックして結果を表示
        echo "{\"decision\":\"block\",\"reason\":$ESCAPED_MSG}"
        exit 0
    fi
fi

# どちらでもない場合は何もせずにClaudeに処理を渡す
exit 0

---
name: code-review
description: |
  Runs Codex CLI review on uncommitted changes via SubAgent.
  Automatically invoked after completing implementation work (trivial changes may skip).
  Iterates until approval, then proceeds to commit/push/PR.
  Also triggered by explicit /code-review command.
---

# Code Review

Automatically leverage Codex CLI (`codex exec review --uncommitted`) for code review after implementation. This skill uses SubAgent (Task tool) to isolate review output from main context.

## When to Use

**自動実行**: 実装作業が完了し、コミット前にレビューが必要な時。
**明示要求**: ユーザーが `/code-review` と入力した時。

### Skip Condition（軽微な変更）

以下の **すべて** に該当する変更はスキップしてコミットに進んでよい：
- `git diff --stat` で変更対象ファイルが **3つ以下**
- `git diff --stat` で変更行数が合計 **20行以下**
- 以下のカテゴリのいずれか：ドキュメント・コメントのみ / 設定の軽微な変更 / 依存バージョン更新のみ / フォーマット修正のみ

**スキップ禁止**: セキュリティ / CI・CD / Nix 実行パス / シェルスクリプト変更

**Fail-closed**: 明示要求時はスキップ不可。判定に確信がない場合もスキップしない。

スキップする場合、コミットメッセージに `[skip-review]` を含めること。

## Workflow

```
[Implementation completed]
         |
[Invoke code-review skill]
         |
[Explicit /code-review request?]
   +- Yes -> [Run review via SubAgent (Skip不可)]
   +- No  -> [Check skip condition via git diff --stat]
               +- Trivial & confident -> [Skip + 明記] -> [Commit/Push/PR]
               +- Otherwise -> [Launch SubAgent via Task tool]
                                    |
                              [SubAgent: codex exec -> analyze -> return summary]
                                    |
                              [Main context receives summary only]
                                    |
                                +- APPROVED -> Commit/Push/PR
                                +- NEEDS_CHANGES -> Fix -> Re-launch SubAgent -> Loop
```

## Codex Review via SubAgent

コンテキスト圧迫を防ぐため、codex exec は **Task ツール（SubAgent）経由** で実行する。
メインコンテキストには SubAgent の要約のみが返り、codex の生出力は隔離される。

### SubAgent 起動方法

Task ツールを以下のパラメータで呼び出す：

- `subagent_type`: `"general-purpose"`
- `description`: `"Codex code review"`
- `prompt`: 以下のテンプレートを使用

### SubAgent Prompt テンプレート

```
未コミットの変更を Codex CLI でレビューしてください。

## 手順
1. Bash ツールで以下を実行：
```bash
set -euo pipefail
REVIEW_OUTPUT=$(mktemp /tmp/codex-code-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-code-review-err-XXXXXX)

codex exec review --uncommitted \
  -s read-only \
  -C "{作業ディレクトリの絶対パス}" \
  --ephemeral \
  -o "$REVIEW_OUTPUT" \
  2>"$REVIEW_ERR"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] || [ ! -s "$REVIEW_OUTPUT" ]; then
  echo "ERROR: codex exec failed (exit=$EXIT_CODE)" >&2
  cat "$REVIEW_ERR" >&2
  rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"
  exit 1
fi

cat "$REVIEW_OUTPUT"
rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"
```

2. 結果を分析し返す：
   - "APPROVED" + 確認ポイント要約
   - "NEEDS_CHANGES" + 指摘リスト（severity順）
```

### Timeout

Bash ツール呼び出し時に timeout を指定：`300000` (5分)

### Error Handling（fail-closed）

- codex exec が非ゼロ終了 or 出力ファイルが空の場合、SubAgent はエラーを報告して終了
- メインコンテキストはエラー内容を受け取り、ユーザーに判断を仰ぐ

### Iteration

SubAgent は毎回新規起動（ステートレス）。反復時は前回指摘の要約を prompt に含める。最大3回。

### Fallback（Task ツール不可時）

Task ツールが利用できない環境では、従来の Bash ツール直接実行にフォールバックする。その場合、codex exec の生出力がメインコンテキストに入ることを許容する。

## Integration with Commit Workflow

### Reviewed by Codex（SubAgent 経由）
1. SubAgent から返された要約をユーザーに提示
2. 「Codex reviewed and approved (via SubAgent)」と明記
3. コミット・プッシュ・PR 作成に進む

### Skipped（trivial change）
1. 明記: "Codex review: skipped (trivial change)"
2. Skip 理由を1行で記載（file count / category / line count）
3. コミットメッセージに `[skip-review]` を含めてコミット・プッシュ・PR 作成に進む

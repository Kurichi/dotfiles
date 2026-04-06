---
name: code-review
description: |
  Runs Codex CLI review on uncommitted changes via SubAgent.
  Automatically invoked after completing implementation work (trivial changes may skip).
  3-tier system: Deep (gpt-5.4, adversarial), Standard (gpt-5.4-mini), Skip.
  Iterates until approval, then proceeds to commit/push/PR.
  Also triggered by explicit /code-review command.
---

# Code Review

Automatically leverage Codex CLI for code review after implementation. This skill uses SubAgent (Task tool) to isolate review output from main context.

## When to Use

**自動実行**: 実装作業が完了し、コミット前にレビューが必要な時。
**明示要求**: ユーザーが `/code-review` と入力した時。

## Tier System

| Tier | モデル | 手法 | Timeout |
|------|--------|------|---------|
| **Deep** | `gpt-5.4` | `codex exec` + `--output-schema` で構造化 adversarial review | 600s (10min) |
| **Standard** | `gpt-5.4-mini` | `codex exec review --uncommitted` でネイティブレビュー | 300s (5min) |
| **Skip** | — | レビューなし | — |

## Tier Selection（定性的・上から順に評価）

ファイル数や行数ではなく、**変更の性質と複雑さ**で判断する。大量のファイルでも処理が単純（リネーム、フォーマット統一等）なら軽微。少量でもロジックが複雑なら Deep。

```
1. 明示要求（/code-review）→ skip_allowed = false
2. Deep 条件に該当 → Deep
3. Skip 条件に該当 AND skip_allowed → Skip
4. 判定に確信がない場合 → Standard（fail-closed）
5. それ以外すべて → Standard
```

### Deep 条件（いずれか1つ以上）

- セキュリティ関連（認証・認可・暗号化・シークレット管理）
- アーキテクチャ変更（新モジュール追加、設計パターン導入・変更、依存関係の大幅な変更）
- データスキーマ / API コントラクト変更
- 既存の動作を変更するリファクタリング
- 複数の関心事にまたがる複雑なロジック変更

### Skip 条件（すべてに該当）

- 変更が単純で機械的（ドキュメント・コメントのみ / フォーマット修正 / 依存バージョン更新 / 設定値の微調整 / 大量ファイルの単純リネーム等）
- セキュリティ / CI・CD / Nix 実行パスに影響しない

スキップする場合、コミットメッセージに `[skip-review]` を含めること。

### Standard

Deep でも Skip でもない通常の変更。

## Workflow

```
[Implementation completed]
         |
[Invoke code-review skill]
         |
[Explicit /code-review request?]
   +- Yes -> skip_allowed = false
   +- No  -> skip_allowed = true
         |
[Assess change complexity]
   +- Deep condition     -> [Launch SubAgent: Deep tier]
   +- Skip condition     -> [Skip + 明記] -> [Commit/Push/PR]
   +- Otherwise/Unsure   -> [Launch SubAgent: Standard tier]
                                    |
                              [SubAgent: codex exec -> analyze -> return summary]
                                    |
                              [Main context receives summary only]
                                    |
                                +- APPROVED -> Commit/Push/PR
                                +- NEEDS_CHANGES -> Fix -> Re-launch SubAgent -> Loop (max 3)
```

## Codex Review via SubAgent

コンテキスト圧迫を防ぐため、codex exec は **Task ツール（SubAgent）経由** で実行する。
メインコンテキストには SubAgent の要約のみが返り、codex の生出力は隔離される。

### SubAgent 起動方法

Task ツールを以下のパラメータで呼び出す：

- `subagent_type`: `"general-purpose"`
- `description`: `"Codex code review"`
- `prompt`: ティアに応じたテンプレートを使用

### Deep Tier — SubAgent Prompt テンプレート

```
あなたの唯一のタスクは、以下の Bash コマンドを実行し、その出力を分析することです。
自分で git status を確認したり、独自に判断したりしないでください。必ず Bash ツールでコマンドを実行してください。

## 手順
1. Bash ツールで以下を実行（timeout: 600000）：
```bash
set -euo pipefail
umask 077
REVIEW_OUTPUT=$(mktemp /tmp/codex-code-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-code-review-err-XXXXXX)
trap 'rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"' EXIT

cd "{作業ディレクトリの絶対パス}"
SCHEMA_PATH="config/claude/skills/code-review/review-output.schema.json"

# 一時 index で untracked ファイルを含む diff を取得（実際の index を汚さない）
# git add -N は .gitignore を尊重するため、無視対象ファイルは含まれない
TMP_INDEX=$(mktemp /tmp/codex-git-index-XXXXXX)
trap 'rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR" "$TMP_INDEX"' EXIT
cp "$(git rev-parse --git-dir)/index" "$TMP_INDEX"
# git add -N は .gitignore を尊重するため、秘密情報の除外は .gitignore に委任する
# 追加の pathspec 除外はサブストリングマッチによる誤除外リスクがあるため使用しない
GIT_INDEX_FILE="$TMP_INDEX" git add -N .

# diff を明示的に取得してプロンプトに含める（codex exec には --uncommitted がないため）
{
  printf '%s\n\n' "You are an adversarial code reviewer. Challenge design decisions, identify failure modes, security concerns, and edge cases. Be thorough and critical."
  printf '%s\n\n' "## Uncommitted Changes"
  GIT_INDEX_FILE="$TMP_INDEX" git diff HEAD
  GIT_INDEX_FILE="$TMP_INDEX" git diff HEAD --stat
} | codex exec \
  -m gpt-5.4 -c model_reasoning_effort="xhigh" \
  -s read-only \
  --ephemeral \
  --output-schema "$SCHEMA_PATH" \
  -o "$REVIEW_OUTPUT" \
  - \
  2>"$REVIEW_ERR"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] || [ ! -s "$REVIEW_OUTPUT" ]; then
  echo "ERROR: codex exec failed (exit=$EXIT_CODE)" >&2
  cat "$REVIEW_ERR" >&2
  exit 1
fi

# JSON スキーマ検証
if ! jq -e '.verdict' "$REVIEW_OUTPUT" >/dev/null 2>&1; then
  echo "WARN: invalid JSON output, treating as raw text" >&2
  cat "$REVIEW_OUTPUT"
  exit 0
fi

cat "$REVIEW_OUTPUT"
```

2. 結果を分析し返す：
   - JSON の verdict フィールドで判定：
     - "approve" → "APPROVED" + summary を返す
     - "needs-attention" → "NEEDS_CHANGES" + findings リスト（severity順）を返す
   - JSON パース失敗時 → "NEEDS_CHANGES" + 生出力を返す（fail-closed）
```

### Standard Tier — SubAgent Prompt テンプレート

```
あなたの唯一のタスクは、以下の Bash コマンドを実行し、その出力を分析することです。
自分で git status を確認したり、独自に判断したりしないでください。必ず Bash ツールでコマンドを実行してください。

## 手順
1. Bash ツールで以下を実行（timeout: 300000）：
```bash
set -euo pipefail
umask 077
REVIEW_OUTPUT=$(mktemp /tmp/codex-code-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-code-review-err-XXXXXX)
trap 'rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"' EXIT

cd "{作業ディレクトリの絶対パス}"

codex exec review --uncommitted \
  -m gpt-5.4-mini \
  --ephemeral \
  >"$REVIEW_OUTPUT" 2>"$REVIEW_ERR"

EXIT_CODE=$?
# 正常終了かつ stdout が空の場合、stderr がレビュー本文を含むか検証してからフォールバック
# stderr に警告ログのみが含まれる場合は昇格しない（誤検出防止）
if [ $EXIT_CODE -eq 0 ] && [ ! -s "$REVIEW_OUTPUT" ] && [ -s "$REVIEW_ERR" ]; then
  if grep -qiE '(LGTM|looks good|approved|no issues|finding|severity|P[0-3])' "$REVIEW_ERR"; then
    cp "$REVIEW_ERR" "$REVIEW_OUTPUT"
  fi
fi

if [ $EXIT_CODE -ne 0 ] || [ ! -s "$REVIEW_OUTPUT" ]; then
  echo "ERROR: codex exec review failed (exit=$EXIT_CODE)" >&2
  cat "$REVIEW_ERR" >&2
  exit 1
fi

cat "$REVIEW_OUTPUT"
```

2. 結果を分析し返す：
   - "LGTM", "Looks good", "Approved", "No issues" を含み、具体的な指摘がない → "APPROVED" + 確認ポイント要約
   - それ以外すべて（曖昧な出力含む）→ "NEEDS_CHANGES" + 指摘リスト（severity順）
   - 判定に確信がない場合 → "NEEDS_CHANGES"（fail-closed）
```

### Error Handling（fail-closed）

- codex exec が非ゼロ終了 or 出力ファイルが空の場合、SubAgent はエラーを報告して終了
- メインコンテキストはエラー内容を受け取り、ユーザーに判断を仰ぐ

### Codex Not Installed

```
If codex command is not found:
1. Inform user: "codex CLI がインストールされていません"
2. Suggest: PATH 確認と pnpm add -g @openai/codex を案内
3. Action: 停止（自動スキップしない）
```

### Iteration

SubAgent は毎回新規起動（ステートレス）。反復時は前回指摘の要約を prompt に含める。最大3回。

3回反復しても通過しない場合：
1. 残りの懸念事項をユーザーに要約
2. ユーザーに判断を仰ぐ（続行 / 中止）

### Fallback（Task ツール不可時）

Task ツールが利用できない環境では、従来の Bash ツール直接実行にフォールバックする。その場合、codex exec の生出力がメインコンテキストに入ることを許容する。

## Integration with Commit Workflow

### Reviewed by Codex（SubAgent 経由）
1. SubAgent から返された要約をユーザーに提示
2. 「Codex reviewed and approved (via SubAgent)」と明記
3. コミット・プッシュ・PR 作成に進む

### Skipped（trivial change）
1. 明記: "Codex review: skipped (trivial change)"
2. Skip 理由を1行で記載
3. コミットメッセージに `[skip-review]` を含めてコミット・プッシュ・PR 作成に進む

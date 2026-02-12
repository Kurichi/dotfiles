---
name: plan-review
description: |
  Proactively initiates Codex CLI review when completing a plan in plan mode.
  Use this skill AUTOMATICALLY before calling ExitPlanMode to get peer review on implementation plans.
  The skill uses `codex exec` directly (not MCP), runs synchronously with real-time output, and iterates until approval.
  Also triggered by explicit /plan-review command.
---

# Plan Review

Automatically leverage Codex CLI (`codex exec`) for plan review before exiting plan mode. This skill executes Codex synchronously via Bash, providing real-time progress visibility and straightforward error handling.

## When to Use

**IMPORTANT: This skill should be invoked AUTOMATICALLY before ExitPlanMode.**

Use this skill in these scenarios:

1. **Before ExitPlanMode** - Automatically when you have completed an implementation plan
2. **Explicit request** - When user types `/plan-review` or asks for plan review
3. **Complex plans** - Multi-file changes, architectural decisions, or security-sensitive implementations

**Decision heuristic:** If you're about to call ExitPlanMode and have a non-trivial plan, use this skill first.

## Workflow

```
[Plan completed in plan mode]
         ↓
[Invoke plan-review skill]
         ↓
[Read plan file content]
         ↓
[Assess complexity → Select tier (Standard / Thorough)]
         ↓
[Run codex exec via Bash with review prompt (output → temp file)]
         ↓
[Read output file with Read tool]
         ↓
[Analyze Codex response]
         ↓
  ├─ Approved → Clean up temp files → Proceed to ExitPlanMode
  ├─ Issues found → Modify plan → Re-run codex exec with context → Loop
  └─ Questions → Answer → Re-run codex exec with context → Loop
```

## Complexity Assessment & Tier Selection

プランの内容を読み取り、複雑さに応じて Codex の実行ティアを選択する。

### Tiers

| Tier | Profile | Model | Reasoning | 方針 |
|------|---------|-------|-----------|------|
| **Thorough** | `-p thorough-review` | `gpt-5.1-codex-max` | `xhigh` | 精度重視。deep reasoning 特化モデルで複雑なアーキテクチャを深く分析 |
| **Standard** | *(省略)* | デフォルト | デフォルト | バランス型。高速かつ十分な推論能力で通常のレビューを処理 |

### Thorough を選択する条件（いずれか1つ以上に該当）

- 変更対象ファイルが **5つ以上**
- **アーキテクチャ変更**を伴う（新モジュール追加、設計パターン導入・変更、依存関係の大幅な変更）
- **セキュリティ関連**の変更（認証・認可、暗号化、権限制御、シークレット管理）
- **データスキーマ変更**（DB スキーマ、API コントラクト、データモデル）
- **既存の動作変更**を伴うリファクタリング

### Standard（上記に該当しない場合）

通常の機能追加、バグ修正、設定変更、ドキュメント更新など。

### Codex config.toml でのプロファイル定義

`$CODEX_HOME/config.toml`（`~/.config/codex/config.toml`）に以下のプロファイルを定義済み：

```toml
[profiles.thorough-review]
model = "gpt-5.1-codex-max"
model_reasoning_effort = "xhigh"
```

> Standard tier はデフォルト設定をそのまま使用するためプロファイル定義不要。

## Codex Exec Usage

### Core Command Pattern

プロンプトは **stdin 経由**で渡す（コマンド引数だと `ps` で露出するリスクがあるため）。

**重要:** heredoc (`cat <<'EOF'`) ではなく `printf` + `cat` パイプを使用すること。heredoc はレビュー対象テキスト内に区切り文字と同じ行が含まれると早期終了し、後続行がシェルとして実行されるリスクがある。

**Standard tier（デフォルト）:**
```bash
set -euo pipefail

REVIEW_OUTPUT=$(mktemp /tmp/codex-plan-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-plan-review-err-XXXXXX)
# Pre-validate plan file
test -r "$PLAN_FILE" || { echo "Error: PLAN_FILE not readable: $PLAN_FILE" >&2; exit 1; }

# Truncate output before each iteration (prevents stale output reuse)
: > "$REVIEW_OUTPUT"

{
  printf '%s\n\n' "You are reviewing an implementation plan. Please analyze it for:"
  printf '%s\n' "1. **Correctness** - Will this approach work? Any logical flaws?"
  printf '%s\n' "2. **Completeness** - Are all necessary steps included? Any missing edge cases?"
  printf '%s\n' "3. **Architecture** - Is this the right approach? Better patterns available?"
  printf '%s\n' "4. **Security** - Any potential vulnerabilities introduced?"
  printf '%s\n\n' "5. **Performance** - Any obvious performance concerns?"
  printf '%s\n\n' "If the plan looks good, respond with \"LGTM\" or \"Approved\"."
  printf '%s\n\n' "## Plan to Review"
  cat -- "$PLAN_FILE" || exit 1
  printf '\n---\n\n%s\n' "確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。"
} | codex exec \
  -s read-only \
  -C "$(pwd)" \
  --ephemeral \
  -o "$REVIEW_OUTPUT" \
  - 2>"$REVIEW_ERR"
```

**Thorough tier（複雑なプラン）:**
```bash
set -euo pipefail

REVIEW_OUTPUT=$(mktemp /tmp/codex-plan-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-plan-review-err-XXXXXX)
# Pre-validate plan file
test -r "$PLAN_FILE" || { echo "Error: PLAN_FILE not readable: $PLAN_FILE" >&2; exit 1; }

# Truncate output before each iteration (prevents stale output reuse)
: > "$REVIEW_OUTPUT"

{
  printf '%s\n\n' "You are reviewing an implementation plan. Please analyze it for:"
  printf '%s\n' "1. **Correctness** - Will this approach work? Any logical flaws?"
  printf '%s\n' "2. **Completeness** - Are all necessary steps included? Any missing edge cases?"
  printf '%s\n' "3. **Architecture** - Is this the right approach? Better patterns available?"
  printf '%s\n' "4. **Security** - Any potential vulnerabilities introduced?"
  printf '%s\n\n' "5. **Performance** - Any obvious performance concerns?"
  printf '%s\n\n' "If the plan looks good, respond with \"LGTM\" or \"Approved\"."
  printf '%s\n\n' "## Plan to Review"
  cat -- "$PLAN_FILE" || exit 1
  printf '\n---\n\n%s\n' "確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。"
} | codex exec \
  -p thorough-review \
  -s read-only \
  -C "$(pwd)" \
  --ephemeral \
  -o "$REVIEW_OUTPUT" \
  - 2>"$REVIEW_ERR"
```

### Key Flags

- `-s read-only`: Codex がファイルを変更できないようにする（レビュー専用）
- `--ephemeral`: セッション履歴を汚さない
- `-o FILE`: 最終メッセージをファイルに出力 → Claude Code が Read で取得
- `-C "$(pwd)"`: カレントディレクトリを作業ディレクトリとして指定
- `-` (ハイフン): stdin からプロンプトを読み取る指定
- `--full-auto` は**使用しない**（暗黙的に `--sandbox workspace-write` を設定するため `-s read-only` と競合）
- `-p thorough-review`: Thorough tier 時のみ指定。`config.toml` の `gpt-5.1-codex-max` + `xhigh` reasoning プロファイルを使用

### Why Not Heredoc

heredoc (`cat <<'DELIM'`) はレビュー対象テキスト内に区切り文字（`DELIM`）と同一の行が含まれると早期終了し、後続行がシェルコマンドとして実行されるリスクがある。`printf` + `cat` パイプパターンはこのリスクを完全に排除する。

### Output File Verification

コマンド実行後、`test -s "$REVIEW_OUTPUT"` で出力ファイルが存在かつ非空であることを確認する。空/未生成の場合はエラーとして扱う（fail-closed）。

## Review Prompt Template

`codex exec` に渡すプロンプト構造：

```
You are reviewing an implementation plan. Please analyze it for:

1. **Correctness** - Will this approach work? Any logical flaws?
2. **Completeness** - Are all necessary steps included? Any missing edge cases?
3. **Architecture** - Is this the right approach? Better patterns available?
4. **Security** - Any potential vulnerabilities introduced?
5. **Performance** - Any obvious performance concerns?

If the plan looks good, respond with "LGTM" or "Approved".
If you have concerns, list them with specific suggestions.

---

## Plan to Review

[INSERT PLAN CONTENT HERE]

---

確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。
```

## Iteration (Stateless)

`codex exec` は単発実行のため、反復時は毎回フルコンテキストを送る：

```
Iteration 1: レビュー依頼 + プラン内容
Iteration 2: 前回の指摘要約 + 修正差分 + 修正済みプラン全文
Iteration 3: 同上（最大3回）
```

2回目以降は「前回指摘 + 修正差分 + 現行全文」に圧縮し、コスト・待ち時間を抑える。

### Iteration Prompt Template (2回目以降)

```
You are reviewing an updated implementation plan. This is iteration N of review.

## Previous Review Feedback
[SUMMARY OF PREVIOUS FEEDBACK]

## Changes Made
[DIFF OR DESCRIPTION OF CHANGES]

## Updated Plan (Full)
[FULL UPDATED PLAN CONTENT]

---

確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。
```

## Completion Detection

Codex の出力を Read で取得し、以下の基準で次のアクションを判定する：

### Approved (Proceed to ExitPlanMode)
- Contains: "LGTM", "Looks good", "Approved", "No issues", "Good to go"
- Tone: Positive without new concerns or questions
- No action items listed

### Needs Modification
- Lists specific issues or concerns
- Suggests alternative approaches
- Points out missing considerations
- Action: Modify the plan, then re-run `codex exec` with iteration context

### Questions/Clarification Needed
- Asks questions about the approach
- Needs more context
- Action: Provide answers in next `codex exec` iteration

## Iteration Limit

**Maximum iterations: 3**

If after 3 rounds of feedback the plan is still not approved:
1. Summarize the remaining concerns to the user
2. Ask the user whether to:
   - Continue iterating manually
   - Proceed with ExitPlanMode despite concerns
   - Abandon the plan and reconsider

## Error Handling (Fail-closed)

デフォルトは **fail-closed**（レビュー失敗時は停止し、ユーザーに明示的な判断を求める）。

### Codex Not Installed
```
If codex command is not found:
1. Inform user: "codex CLI がインストールされていません"
2. Suggest: PATH 確認と npm install -g @openai/codex を案内
3. Action: 停止（自動スキップしない）
```

### Non-zero Exit Code
```
If codex exec returns non-zero exit code:
1. Read $REVIEW_ERR to get error details
2. Summarize error to user
3. Ask user: "リトライ / レビューなしで続行" を確認（自動スキップしない）
```

### Timeout
```
Bash tool の timeout パラメータを使用：
- Standard tier: 300000ms (5分)
- Thorough tier: 600000ms (10分)
タイムアウト時はユーザーに報告して判断を仰ぐ
```

### Profile Not Found
```
If codex exec fails with profile not found error (e.g. "config profile 'thorough-review' not found"):
1. Fallback: -m gpt-5.1-codex-max -c model_reasoning_effort="xhigh" でインライン指定にフォールバック
2. Inform user that the thorough-review profile is not configured in $CODEX_HOME/config.toml
```

### Empty Output File
```
If $REVIEW_OUTPUT is empty or does not exist after execution:
1. Read $REVIEW_ERR for error details
2. Report to user as review failure
3. Action: 停止（自動スキップしない）
```

## Temporary File Cleanup

**重要:** `trap ... EXIT` は使用しない。Bash ツールの呼び出し終了時にファイルが削除され、次の Read ツールで読めなくなるため。

クリーンアップは以下の手順で行う：
1. `codex exec` を Bash ツールで実行（出力ファイルパスを記録）
2. Read ツールで `$REVIEW_OUTPUT` を読み取り、内容を確認
3. レビュー完了後（全イテレーション終了後）に Bash ツールで `rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"` を実行

反復ループ内では同一ファイルパスを再利用する。

**反復時のステール出力防止:** 各イテレーション実行前に `: > "$REVIEW_OUTPUT"` で出力ファイルを truncate すること。これにより、再実行が書き込み前に失敗した場合に前回の出力を誤って読み取ることを防ぐ。判定は常にコマンド終了コードを先に確認し、成功時のみ出力ファイルを読む。

## Example Usage

### Automatic Invocation (Before ExitPlanMode)

```
[Claude Code completes plan in plan mode]

Claude Code thinks: "I'm about to call ExitPlanMode. Let me invoke plan-review first."

Claude Code:
1. Reads plan file content
2. Assesses complexity:
   - "This plan modifies 8 files and introduces a new auth middleware → Thorough"
3. Runs codex exec via Bash with review prompt + -p thorough-review
4. Reads output file with Read tool → feedback: "Consider adding error handling for case X"
5. Updates plan to address feedback
6. Re-runs codex exec with iteration context (previous feedback + updated plan)
7. Reads output file with Read tool → "LGTM, the plan looks complete now"
8. Cleans up temp files with Bash: rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"
9. Proceeds to ExitPlanMode
```

### Explicit Invocation

```
User: /plan-review

Claude Code:
1. Identifies current plan file (if in plan mode) or asks for plan content
2. Assesses complexity → Selects tier (Thorough or Standard)
3. Runs codex exec via Bash with review prompt
4. Iterates until approval or user decision
```

## Integration with ExitPlanMode

After receiving approval from Codex:

1. Include review summary in your message to user
2. Mention that the plan was reviewed by Codex
3. Call ExitPlanMode

Example message:
```
The implementation plan has been reviewed by Codex and approved.
Key points confirmed:
- [Summary of what was validated]
- [Any minor suggestions incorporated]

Proceeding with plan approval request.
```

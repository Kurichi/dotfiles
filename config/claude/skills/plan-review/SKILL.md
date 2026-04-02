---
name: plan-review
description: |
  Proactively initiates Codex CLI review when completing a plan in plan mode.
  Use this skill AUTOMATICALLY before calling ExitPlanMode to get peer review on implementation plans (trivial changes may skip).
  3-tier system: Deep (gpt-5.4), Standard (gpt-5.4-mini), Skip.
  The skill uses `codex exec` via SubAgent (Task tool) to isolate review output from main context.
  Also triggered by explicit /plan-review command.
---

# Plan Review

Automatically leverage Codex CLI (`codex exec`) for plan review before exiting plan mode. This skill uses SubAgent (Task tool) to isolate review output from main context, preventing context window bloat.

## When to Use

**IMPORTANT: This skill should be invoked AUTOMATICALLY before ExitPlanMode（軽微な変更を除く）。**

Use this skill in these scenarios:

1. **Before ExitPlanMode** - Automatically when you have completed a non-trivial implementation plan
2. **Explicit request** - When user types `/plan-review` or asks for plan review

**Fail-closed principle:**
- 明示的な `/plan-review` 要求がある場合、Skip Condition より明示要求を優先してレビューを実行する。
- 判定に確信が持てない場合はスキップせずレビューを実行する。

## Tier System

| Tier | モデル | Profile | Timeout |
|------|--------|---------|---------|
| **Deep** | `gpt-5.4` | `-p deep-review` | 600s (10min) |
| **Standard** | `gpt-5.4-mini` | `-p fast-review` | 300s (5min) |
| **Skip** | — | — | — |

### Codex config.toml でのプロファイル定義

`$CODEX_HOME/config.toml`（`~/.config/codex/config.toml`）に以下のプロファイルを定義済み：

```toml
[profiles.deep-review]
model = "gpt-5.4"
model_reasoning_effort = "xhigh"

[profiles.fast-review]
model = "gpt-5.4-mini"
model_reasoning_effort = "high"
```

## Tier Selection（code-review と同じ定性的基準）

ファイル数や行数ではなく、**変更の性質と複雑さ**で判断する。プランの内容から変更の性質を読み取る。

```
1. 明示要求（/plan-review）→ skip_allowed = false
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

### Standard

Deep でも Skip でもない通常の変更。

## Workflow

```
[Plan completed in plan mode]
         |
[Invoke plan-review skill]
         |
[Read plan file content]
         |
[Explicit /plan-review request?]
   +- Yes -> skip_allowed = false
   +- No  -> skip_allowed = true
         |
[Assess change complexity from plan content]
   +- Deep condition     -> [Launch SubAgent: Deep tier]
   +- Skip condition     -> [Skip + 明記] -> [ExitPlanMode]
   +- Otherwise/Unsure   -> [Launch SubAgent: Standard tier]
                                    |
                              [SubAgent: codex exec -> analyze -> return summary]
                                    |
                              [Main context receives summary only]
                                    |
                                +- Approved -> Proceed to ExitPlanMode
                                +- Issues found -> Modify plan -> Re-launch SubAgent -> Loop
                                +- Questions -> Answer -> Re-launch SubAgent -> Loop
```

## Codex Review via SubAgent

コンテキスト圧迫を防ぐため、codex exec は **Task ツール（SubAgent）経由** で実行する。
メインコンテキストには SubAgent の要約のみが返り、codex の生出力は隔離される。

### SubAgent 起動方法

Task ツールを以下のパラメータで呼び出す：

- `subagent_type`: `"general-purpose"`
- `description`: `"Codex plan review"`
- `prompt`: ティアに応じたテンプレートを使用

### Deep Tier — SubAgent Prompt テンプレート

```
以下のプランを Codex CLI でレビューしてください。

## 手順
1. Read ツールでプランファイルを読む: {プランファイルパス}
2. Bash ツールで codex exec を実行する（timeout: 600000）：
```bash
set -euo pipefail
umask 077
PLAN_FILE="{プランファイルパス}"
REVIEW_OUTPUT=$(mktemp /tmp/codex-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-review-err-XXXXXX)
trap 'rm -f "$REVIEW_OUTPUT" "$REVIEW_ERR"' EXIT

{
  printf '%s\n\n' "You are reviewing an implementation plan as an adversarial reviewer. Challenge design decisions, identify failure modes, and question assumptions. Analyze for:"
  printf '%s\n' "1. Correctness - Will this approach work?"
  printf '%s\n' "2. Completeness - Any missing steps or edge cases?"
  printf '%s\n' "3. Architecture - Is this the right approach?"
  printf '%s\n' "4. Security - Any vulnerabilities?"
  printf '%s\n\n' "5. Performance - Any concerns?"
  printf '%s\n\n' "If good, respond with 'LGTM'. Otherwise list specific issues."
  printf '%s\n\n' "## Plan to Review"
  cat -- "$PLAN_FILE"
  printf '\n---\n\n%s\n' "確認や質問は不要。具体的な提案・修正案まで出力してください。"
} | codex exec -p deep-review -s read-only -C "$(pwd)" --ephemeral -o "$REVIEW_OUTPUT" - 2>"$REVIEW_ERR"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] || [ ! -s "$REVIEW_OUTPUT" ]; then
  echo "ERROR: codex exec failed (exit=$EXIT_CODE)" >&2
  cat "$REVIEW_ERR" >&2
  exit 1
fi

cat "$REVIEW_OUTPUT"
```

注意: プランファイルは disk 上に存在するので cat で直接読む（heredoc 不要、インジェクションリスクなし）。

3. 結果を分析し、以下のいずれかを返す：
   - "APPROVED" + 確認されたポイントの要約（2-3行）
   - "NEEDS_CHANGES" + 具体的な指摘事項のリスト（severity順）
```

### Standard Tier — SubAgent Prompt テンプレート

Deep tier と同じだが、codex exec のプロファイルと prompt が異なる：

```bash
# 変更箇所のみ：
# -p deep-review → -p fast-review
# adversarial reviewer → 通常のレビュー
codex exec -p fast-review -s read-only -C "$(pwd)" --ephemeral -o "$REVIEW_OUTPUT" - 2>"$REVIEW_ERR"
```

prompt の冒頭を以下に変更：
```
"You are reviewing an implementation plan. Analyze for:"
```
（"adversarial reviewer" や "Challenge design decisions" 等の文言を除く）

### Timeout

Bash ツール呼び出し時に timeout を指定：
- Deep tier: `600000` (10分)
- Standard tier: `300000` (5分)

### Error Handling（fail-closed）

デフォルトは **fail-closed**（レビュー失敗時は停止し、ユーザーに明示的な判断を求める）。

- codex exec が非ゼロ終了 or 出力ファイルが空の場合、SubAgent はエラーを報告して終了
- メインコンテキストはエラー内容を受け取り、ユーザーに判断を仰ぐ

### Codex Not Installed
```
If codex command is not found:
1. Inform user: "codex CLI がインストールされていません"
2. Suggest: PATH 確認と pnpm add -g @openai/codex を案内
3. Action: 停止（自動スキップしない）
```

### Profile Not Found
```
If codex exec fails with profile not found error:
1. Fallback: インライン指定にフォールバック
   - Deep: -m gpt-5.4 -c model_reasoning_effort="xhigh"
   - Standard: -m gpt-5.4-mini -c model_reasoning_effort="high"
2. Inform user that the profile is not configured in $CODEX_HOME/config.toml
```

### Iteration

SubAgent は毎回新規起動（ステートレス）。反復時は修正済みプラン全文 + 前回指摘の要約を prompt に含める。最大3回。

3回反復しても通過しない場合：
1. 残りの懸念事項をユーザーに要約
2. ユーザーに判断を仰ぐ（続行 / ExitPlanMode / 中止）

### Fallback（Task ツール不可時）

Task ツールが利用できない環境では、従来の Bash ツール直接実行にフォールバックする。その場合、codex exec の生出力がメインコンテキストに入ることを許容する。

## Completion Detection

SubAgent の出力を分析し、以下の基準で次のアクションを判定する：

### Approved (Proceed to ExitPlanMode)
- Contains: "LGTM", "Looks good", "Approved", "No issues", "Good to go"
- Tone: Positive without new concerns or questions
- No action items listed

### Needs Modification
- Lists specific issues or concerns
- Suggests alternative approaches
- Points out missing considerations
- Action: Modify the plan, then re-launch SubAgent with iteration context

### Questions/Clarification Needed
- Asks questions about the approach
- Needs more context
- Action: Provide answers in next SubAgent iteration

### 判定に確信がない場合
- NEEDS_CHANGES 扱い（fail-closed）

## Integration with ExitPlanMode

### Reviewed by Codex（SubAgent 経由）
1. SubAgent から返された要約をユーザーに提示
2. 「Codex reviewed and approved (via SubAgent)」と明記
3. Call ExitPlanMode

### Skipped（trivial change）
1. 明記: "Codex review: skipped (trivial change)"
2. Skip 理由を1行で記載
3. Call ExitPlanMode

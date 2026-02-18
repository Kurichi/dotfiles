---
name: plan-review
description: |
  Proactively initiates Codex CLI review when completing a plan in plan mode.
  Use this skill AUTOMATICALLY before calling ExitPlanMode to get peer review on implementation plans (trivial changes may skip).
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

### Skip Condition（軽微な変更 — plan-review 用）

プランモード時は diff 行数が確定しないため、ファイル数とカテゴリのみで判定する。

以下の **すべて** に該当するプランはスキップして直接 ExitPlanMode してよい：
- 変更対象ファイルが **3つ以下**
- 以下のカテゴリのいずれかに該当：
  - ドキュメント・コメントのみの変更
  - 設定ファイルの軽微な変更（typo修正、値の微調整）
  - 依存バージョン更新のみ
  - フォーマット修正のみ

**スキップ禁止**（以下のいずれかに該当する場合はスキップ不可）：
- セキュリティ関連の変更
- CI/CD パイプラインの変更
- Nix 設定の実行パス変更
- シェルスクリプト・実行可能ファイルの変更

## Workflow

```
[Plan completed in plan mode]
         |
[Invoke plan-review skill]
         |
[Read plan file content]
         |
[Explicit /plan-review request?]
   +- Yes -> [Run review via SubAgent (Skip不可)]
   +- No  -> [Check skip condition]
               +- Trivial & confident -> [Skip + 明記] -> [ExitPlanMode]
               +- Otherwise -> [Assess complexity -> Select tier]
                                    |
                              [Launch SubAgent via Task tool]
                                    |
                              [SubAgent: codex exec -> analyze -> return summary]
                                    |
                              [Main context receives summary only]
                                    |
                                +- Approved -> Proceed to ExitPlanMode
                                +- Issues found -> Modify plan -> Re-launch SubAgent -> Loop
                                +- Questions -> Answer -> Re-launch SubAgent -> Loop
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

## Codex Review via SubAgent

コンテキスト圧迫を防ぐため、codex exec は **Task ツール（SubAgent）経由** で実行する。
メインコンテキストには SubAgent の要約のみが返り、codex の生出力は隔離される。

### SubAgent 起動方法

Task ツールを以下のパラメータで呼び出す：

- `subagent_type`: `"general-purpose"`
- `description`: `"Codex plan review"`
- `prompt`: 以下のテンプレートを使用

### SubAgent Prompt テンプレート

#### Standard tier

```
以下のプランを Codex CLI でレビューしてください。

## 手順
1. Read ツールでプランファイルを読む: {プランファイルパス}
2. Bash ツールで codex exec を実行する（下記コマンド参照）
3. 結果を分析し、以下のいずれかを返す：
   - "APPROVED" + 確認されたポイントの要約（2-3行）
   - "NEEDS_CHANGES" + 具体的な指摘事項のリスト（severity順）

## codex exec コマンド（Bash ツールで実行）
```bash
set -euo pipefail
PLAN_FILE="{プランファイルパス}"
REVIEW_OUTPUT=$(mktemp /tmp/codex-review-XXXXXX)
REVIEW_ERR=$(mktemp /tmp/codex-review-err-XXXXXX)

{
  printf '%s\n\n' "You are reviewing an implementation plan. Analyze for:"
  printf '%s\n' "1. Correctness - Will this approach work?"
  printf '%s\n' "2. Completeness - Any missing steps or edge cases?"
  printf '%s\n' "3. Architecture - Is this the right approach?"
  printf '%s\n' "4. Security - Any vulnerabilities?"
  printf '%s\n\n' "5. Performance - Any concerns?"
  printf '%s\n\n' "If good, respond with 'LGTM'. Otherwise list specific issues."
  printf '%s\n\n' "## Plan to Review"
  cat -- "$PLAN_FILE"
  printf '\n---\n\n%s\n' "確認や質問は不要。具体的な提案・修正案まで出力してください。"
} | codex exec -s read-only -C "$(pwd)" --ephemeral -o "$REVIEW_OUTPUT" - 2>"$REVIEW_ERR"

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

注意: プランファイルは disk 上に存在するので cat で直接読む（heredoc 不要、インジェクションリスクなし）。
```

#### Thorough tier（5ファイル以上/アーキテクチャ変更/セキュリティ変更時）

Standard tier と同じだが、codex exec に `-p thorough-review` を追加：
`codex exec -p thorough-review -s read-only -C "$(pwd)" --ephemeral -o "$REVIEW_OUTPUT" -`

### Timeout

Bash ツール呼び出し時に timeout を指定：
- Standard tier: `300000` (5分)
- Thorough tier: `600000` (10分)

### Error Handling（fail-closed）

デフォルトは **fail-closed**（レビュー失敗時は停止し、ユーザーに明示的な判断を求める）。

- codex exec が非ゼロ終了 or 出力ファイルが空の場合、SubAgent はエラーを報告して終了
- メインコンテキストはエラー内容を受け取り、ユーザーに判断を仰ぐ

### Codex Not Installed
```
If codex command is not found:
1. Inform user: "codex CLI がインストールされていません"
2. Suggest: PATH 確認と npm install -g @openai/codex を案内
3. Action: 停止（自動スキップしない）
```

### Profile Not Found
```
If codex exec fails with profile not found error (e.g. "config profile 'thorough-review' not found"):
1. Fallback: -m gpt-5.1-codex-max -c model_reasoning_effort="xhigh" でインライン指定にフォールバック
2. Inform user that the thorough-review profile is not configured in $CODEX_HOME/config.toml
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

## Integration with ExitPlanMode

### Reviewed by Codex（SubAgent 経由）
1. SubAgent から返された要約をユーザーに提示
2. 「Codex reviewed and approved (via SubAgent)」と明記
3. Call ExitPlanMode

### Skipped（trivial change）
1. 明記: "Codex review: skipped (trivial change)"
2. Skip 理由を1行で記載（file count / category）
3. Call ExitPlanMode

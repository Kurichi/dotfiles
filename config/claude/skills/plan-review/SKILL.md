---
name: plan-review
description: |
  Proactively initiates Codex MCP review when completing a plan in plan mode.
  Use this skill AUTOMATICALLY before calling ExitPlanMode to get peer review on implementation plans.
  The skill calls mcp__codex__codex directly (no tmux), analyzes feedback, and iterates until approval.
  Also triggered by explicit /plan-review command.
---

# Plan Review

Automatically leverage Codex MCP for plan review before exiting plan mode. This skill uses MCP tools directly without tmux, providing a streamlined review workflow.

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
[Assess complexity → Select Codex profile]
         ↓
[Call mcp__codex__codex with review request (+ profile when Thorough)]
         ↓
[Analyze Codex response]
         ↓
  ├─ Approved → Proceed to ExitPlanMode
  ├─ Issues found → Modify plan → mcp__codex__codex-reply → Loop
  └─ Questions → Answer → mcp__codex__codex-reply → Loop
```

## Complexity Assessment & Profile Selection

プランの内容を読み取り、複雑さに応じて Codex profile を選択する。

### Profile Tiers

| Tier | Profile | Model | Reasoning | 方針 |
|------|---------|-------|-----------|------|
| **Thorough** | `thorough-review` | `gpt-5.1-codex-max` | `xhigh` | 精度重視。deep reasoning 特化モデルで複雑なアーキテクチャを深く分析 |
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
> `approval-policy` はスキル側で `mcp__codex__codex` 呼び出し時にパラメータとして指定する。

## MCP Tool Usage

### Starting a Review Session

Use `mcp__codex__codex` to initiate the review:

```
Tool: mcp__codex__codex
Parameters:
  prompt: [Review request with full plan content]
  cwd: [Current working directory]
  approval-policy: "never"
  sandbox: "read-only"
  profile: "thorough-review"  # Thorough tier のみ指定。Standard では省略
```

**Important parameters:**
- `approval-policy: "never"` - Codex should only review, not execute commands
- `sandbox: "read-only"` - Ensure Codex cannot modify files during review
- `profile` - Thorough 判定時に `"thorough-review"` を指定。Standard の場合は省略

### Continuing a Review Conversation

Use `mcp__codex__codex-reply` for follow-ups:

```
Tool: mcp__codex__codex-reply
Parameters:
  threadId: [Thread ID from initial response]
  prompt: [Your response or updated plan]
```

## Review Prompt Template

When calling `mcp__codex__codex`, use this prompt structure:

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

Please provide your review.
```

## Completion Detection

Analyze Codex's response to determine next action:

### Approved (Proceed to ExitPlanMode)
- Contains: "LGTM", "Looks good", "Approved", "No issues", "Good to go"
- Tone: Positive without new concerns or questions
- No action items listed

### Needs Modification
- Lists specific issues or concerns
- Suggests alternative approaches
- Points out missing considerations
- Action: Modify the plan, then use `mcp__codex__codex-reply` with updates

### Questions/Clarification Needed
- Asks questions about the approach
- Needs more context
- Action: Provide answers via `mcp__codex__codex-reply`

## Iteration Limit

**Maximum iterations: 3**

If after 3 rounds of feedback the plan is still not approved:
1. Summarize the remaining concerns to the user
2. Ask the user whether to:
   - Continue iterating manually
   - Proceed with ExitPlanMode despite concerns
   - Abandon the plan and reconsider

## Error Handling

### MCP Server Not Connected
```
If mcp__codex__codex fails with connection error:
1. Inform user: "Codex MCP server is not available"
2. Ask user: "Proceed without review, or wait for MCP connection?"
3. If proceed: Continue to ExitPlanMode with warning
```

### Timeout (No Response)
```
If Codex does not respond within reasonable time:
1. Inform user of the delay
2. Offer to retry or proceed without review
```

### Invalid Thread ID
```
If mcp__codex__codex-reply fails:
1. Start a new review session with mcp__codex__codex
2. Include previous context in new prompt
```

### Profile Not Found
```
If mcp__codex__codex fails with profile not found error (e.g. "config profile 'thorough-review' not found"):
1. Retry without profile parameter (fallback to Standard tier)
2. Inform user that the thorough-review profile is not configured in $CODEX_HOME/config.toml
```

## Example Usage

### Automatic Invocation (Before ExitPlanMode)

```
[Claude Code completes plan in plan mode]

Claude Code thinks: "I'm about to call ExitPlanMode. Let me invoke plan-review first."

Claude Code:
1. Reads plan file content
2. Assesses complexity:
   - "This plan modifies 8 files and introduces a new auth middleware → Thorough"
3. Calls mcp__codex__codex with review prompt + profile: "thorough-review"
4. Receives feedback: "Consider adding error handling for case X"
5. Updates plan to address feedback
6. Calls mcp__codex__codex-reply with updated plan
7. Receives: "LGTM, the plan looks complete now"
8. Proceeds to ExitPlanMode
```

### Explicit Invocation

```
User: /plan-review

Claude Code:
1. Identifies current plan file (if in plan mode) or asks for plan content
2. Assesses complexity → Selects profile (Thorough or Standard)
3. Initiates Codex review with selected profile
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

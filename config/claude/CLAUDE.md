## 言語・フレームワーク

特に指示がない限りGo言語を使用してください。

### Go 言語
- APIフレームワークは labstack/echo を使用してください。
- バージョンはその時点での最新安定版を使用してください。
- プロジェクト参加者全員が使用するツールの取得時は `go install` ではなく `go get -tool` を使用してください。
- tool を使用したい時は `go tool tool-name` で使用してください。
- ソースコードの取得は不要な一度限りのコマンドは `go run github.com/xxx/yyy/cmd/yyy` で実行してください。
- gopls MCP Server を使用して LSP を参照してください。

## 使用するコマンド・ツール

### コマンド代替

| 一般的なコマンド | 使用するコマンド |
|------------------|------------------|
| `grep`           | `rg` (ripgrep)   |
| `find`           | `fd`             |
| `ls`             | `eza`            |
| `npm`            | `pnpm`           |
| `npx`            | `pnpx`           |
| `python3`        | `uv run python3` |
| `uv run python something.py` | `uv run something.py` |
| `uv pip install xxx`         | `uv add xxx`          |

### Git コマンド
- ブランチの作成は `git switch` コマンドを使用してください．

### GitHub API
- `gh api` でデータを取得する際は、必ず `--jq` フラグで必要なフィールドのみ抽出すること（トークン節約のため）。
- `diff_hunk` のような長大なフィールドは末尾数行のみ切り出すこと。
- 例：PR レビューコメント取得時:
  ```bash
  gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate \
    --jq '.[] | {id, body, user: .user.login, path, line: (.line // .original_line), diff_hunk: ((.diff_hunk // "") | split("\n") | .[-5:] | join("\n")), in_reply_to_id, created_at}'
  ```

## プルリクエスト
- `./.github/PULL_REQUEST_TEMPLATE.md` が存在する場合，それを元にPRを作成してください．

### 作業ワークフロー
- 作業は必ず git worktree 上で行うこと。main ブランチのワークツリーに直接変更を加えない。
- 一連の作業が完了したら、ユーザーに確認せず自動的に Codex MCP（`mcp__codex__codex`）を使用してレビューを依頼すること。
- Codex MCP のレビューで修正依頼があれば修正し、再度レビューを依頼する。修正依頼がなくなるまで繰り返すこと。
- Codex MCP のレビューが通過したら、ユーザーに確認せず自動的にコミット・プッシュ・PR 作成まで行うこと。

## プランモード

ExitPlanMode を呼ぶ前に、必ず plan-review スキルを使用して Codex MCP にレビューを依頼すること。

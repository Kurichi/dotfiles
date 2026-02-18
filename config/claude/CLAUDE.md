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
- あなたは既に作業用 worktree 内で起動されていることを前提とする。worktree の作成・移動・削除（`gwq add`、`gwq cd`、`gwq remove` 等）は自分で行わないこと。
- main ブランチのワークツリーに直接変更を加えないこと。**起動時のカレントディレクトリから `cd` で離れないこと。**（PreToolUse hook で linked worktree 上での cd/pushd/popd はブロックされる）
- `codex exec` の実行は **Task ツール（SubAgent）経由** で行い、生の出力によるコンテキスト圧迫を防ぐこと。
- 一連の作業が完了したら、code-review スキルを使用してレビューを依頼すること。
- レビューが通過したら、ユーザーに確認せず自動的にコミット・プッシュ・PR 作成まで行うこと。

## プランモード

ExitPlanMode を呼ぶ前に、plan-review スキルを使用して Codex CLI にレビューを依頼すること。ただし、plan-review スキルの「Skip Condition」に該当する場合はスキップしてよい。

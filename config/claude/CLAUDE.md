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
### Linux Command 代替
- grep ではなく ripgrep を使用してください．
- find ではなく fd を使用してください．

### Git コマンド
- ブランチの作成は `git switch` コマンドを使用してください．

## プルリクエスト
- `./.github/PULL_REQUEST_TEMPLATE.md` が存在する場合，それを元にPRを作成してください．

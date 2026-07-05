---
name: pr
description: |
  Pull Request 作成ワークフロー。プロジェクト種別を自動検出し、適切なチェック（Go build/test、tflint）を実行後、コミット・プッシュ・PR作成を行う。
  使用タイミング: PRを作成したい時、/pr と入力された時、「PRを作成して」「PR出して」と依頼された時。
---

# PR Creation Workflow

プロジェクト種別を自動検出し、適切なチェックを実行後、コミット・プッシュ・PR作成を行う。

## Workflow

### 1. プロジェクト検出

以下の条件でプロジェクト種別を判定（複数該当可能）：

| 条件              | プロジェクト種別 |
| ----------------- | ---------------- |
| `go.mod` が存在   | Go プロジェクト  |
| `*.tf` が存在     | Terraform        |

### 2. 条件付きチェック実行

検出したプロジェクト種別に応じてチェックを実行：

#### Go プロジェクト
```bash
go build -o /dev/null ./...
go test ./...
```

#### Terraform プロジェクト
```bash
# go.mod に tflint が tool として登録されている場合
go tool tflint --recursive

# そうでなければ通常の tflint
tflint --recursive
```

**チェック失敗時は停止し、エラー内容を報告して修正を促す。**

### 3. Git 状態確認・コミット

`git status` と `git add` は通常どおり実行してよい。`git commit` は SSH 署名鍵/socket へアクセスするため、最初からサンドボックス外実行（許可要求）で行うこと。サンドボックス内で先に失敗させてから再実行しない。

```bash
# 変更状態を確認
git status

# 変更がある場合のみステージング（機密ファイル除外）
# .env, credentials, secrets などは除外
git add <files>

# Conventional Commit 形式でコミット（SSH 署名のため最初からサンドボックス外実行）
git commit -m "<type>(<scope>): <description>"
```

#### コミットタイプ
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `refactor`: リファクタリング
- `test`: テスト
- `chore`: その他

### 4. プッシュ

SSH remote 認証が必要になるため、リモートブランチ初回の `git push -u origin <branch>` は最初からサンドボックス外実行（許可要求）で行うこと。

```bash
# リモートブランチの有無を確認し、適切にプッシュ（初回 push はサンドボックス外実行）
git push -u origin <branch>
```

### 5. PR 作成

```bash
# テンプレートがあれば参照
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null

# PR 作成
gh pr create --title "<title>" --body "<body>"
```

#### PR タイトル
- 70文字以内
- 変更内容を簡潔に

#### PR 本文
- テンプレートがあれば従う
- なければ以下の形式：

```markdown
## Summary
<変更内容の要約（1-3行）>

## Test plan
- [ ] テスト項目...

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 6. 完了報告

PR URLを出力して完了。

## 注意事項

- 機密ファイル（`.env`, `credentials.json` など）は絶対にコミットしない
- 変更がない場合は PR 作成をスキップ
- コミットメッセージの Co-Authored-By は標準の Claude Code の形式に従う

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS (Apple Silicon) 用のdotfilesリポジトリ。nix-darwinとhome-managerで宣言的に管理。

## よく使うコマンド

```bash
# システム設定を適用（nix-darwin + home-manager）
sudo darwin-rebuild switch --flake .#macos

# 設定ファイルを ~/.config からリポジトリに同期
./sync.sh
```

## アーキテクチャ

### Nix設定の構造

```
flake.nix                 # エントリーポイント（inputs, darwinConfigurations）
nix/
├── darwin.nix            # macOSシステム設定（Homebrew, Dock, Finder, セキュリティ等）
├── home.nix              # ユーザー設定のエントリー（パッケージ、環境変数、launchd）
├── git.nix               # Git設定
├── fish.nix              # Fish shell設定
├── neovim.nix            # Neovim設定（config/nvimをリンク）
├── wezterm.nix           # WezTerm設定（config/weztermをリンク）
├── claude.nix            # Claude Code設定（config/claudeをリンク）
├── vscode.nix            # VSCode拡張機能・設定
└── packages/             # カスタムNixパッケージ定義
```

### アプリケーション設定の構造

```
config/
├── nvim/                 # Neovim設定（lazy.nvimプラグインマネージャー使用）
│   ├── init.lua          # エントリーポイント
│   └── lua/
│       ├── options.lua   # Neovimオプション
│       ├── keymaps.lua   # キーバインド
│       ├── plugins/      # プラグイン定義
│       └── lang/         # 言語固有設定
├── wezterm/              # WezTermターミナル設定
│   ├── wezterm.lua       # メイン設定
│   └── keybinds.lua      # キーバインド
├── fish/functions/       # Fish shell関数
└── claude/               # Claude Code設定
    ├── CLAUDE.md         # グローバルClaude指示（~/.config/claude/にリンク）
    ├── commands/         # カスタムコマンド
    └── skills/           # カスタムスキル
```

### パッケージ管理の階層

1. **nixpkgs**: 大部分のCLIツール・GUIアプリ（`nix/home.nix`で定義）
2. **Homebrew casks**: Nixで提供されていないアプリ（`nix/darwin.nix`）
3. **Mac App Store**: masAppsで管理（`nix/darwin.nix`）
4. **llm-agents flake**: Claude Code等のAIツール

## 注意事項

- `config/` 配下の設定は `~/.config/` にシンボリックリンクされる
- `sync.sh`は `~/.config/` からこのリポジトリへのコピー（逆方向の同期用）

## タスク実行時のワークフロー

タスクを遂行する際は `gwq` を使用して git worktree を作成し、独立した作業環境で実施すること。

### 手順

1. **worktree 作成**: `gwq get <repository>` または `gwq add` で新しい worktree を作成
2. **ディレクトリ移動**: 作成した worktree に `cd` で移動
3. **作業実施**: その worktree 内でタスクを遂行
4. **後処理**: PR がマージされたら `gwq remove` で worktree を削除

### ブランチ命名規則

- 新機能: `feature/説明` (例: `feature/add-auth`)
- バグ修正: `fix/説明` (例: `fix/login-bug`)
- リファクタ: `refactor/説明`
- ドキュメント: `docs/説明`
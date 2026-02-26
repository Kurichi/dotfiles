# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS (Apple Silicon) 用のdotfilesリポジトリ。nix-darwinとhome-managerで宣言的に管理。

## よく使うコマンド

```bash
# システム設定を適用（nix-darwin + home-manager）
nix run .#switch
# または直接実行
sudo darwin-rebuild switch --flake .#macos

# テストビルド（適用せずにビルドのみ）
nix run .#build

# flake inputs を更新
nix run .#update
```

## アーキテクチャ

### Nix設定の構造

```
flake.nix                     # エントリーポイント（inputs, darwinConfigurations, apps）
nix/
├── modules/
│   ├── darwin/               # macOS システム設定
│   │   ├── default.nix       # imports集約 + nix/nixpkgs設定
│   │   ├── system.nix        # Dock, Finder, セキュリティ, ネットワーク等
│   │   └── homebrew.nix      # Homebrew casks, masApps
│   └── home/                 # ユーザー設定
│       ├── default.nix       # imports集約
│       ├── packages.nix      # パッケージ定義
│       ├── dotfiles.nix      # 環境変数
│       ├── launchd.nix       # 自動起動アプリ
│       └── programs/         # プログラムごとのモジュール
│           ├── default.nix   # imports集約
│           ├── git.nix       # Git設定
│           ├── fish.nix      # Fish shell設定
│           ├── fzf.nix       # fzf設定
│           ├── direnv.nix    # direnv設定
│           ├── neovim.nix    # Neovim設定（config/nvimをリンク）
│           ├── vscode.nix    # VSCode拡張機能・設定
│           ├── wezterm.nix   # WezTerm設定（config/weztermをリンク）
│           └── llm-agents.nix # Claude Code/Gemini CLI設定
└── overlays/
    └── default.nix           # overlay集約（現在 no-op）
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

1. **nixpkgs**: 大部分のCLIツール（`nix/modules/home/packages.nix`で定義）
2. **overlays**: カスタムパッケージ（`nix/overlays/`で定義）
3. **Homebrew casks**: Nixで提供されていないGUIアプリ（`nix/modules/darwin/homebrew.nix`）
4. **Mac App Store**: masAppsで管理（`nix/modules/darwin/homebrew.nix`）
5. **llm-agents flake**: Claude Code等のAIツール

## 注意事項

- `config/` 配下の設定は `~/.config/` にシンボリックリンクされる

## タスク実行時のワークフロー

あなたは既に作業用の git worktree 内で起動されていることを前提とする。worktree の作成・削除はユーザーが行う。

- main ブランチのワークツリーに直接変更を加えないこと
- worktree の作成（`git wt <branch>`）、削除（`git wt -d <branch>`）は自分で行わないこと
- **起動時のカレントディレクトリから `cd` で離れないこと**（PreToolUse hook で main worktree への移動はブロックされる）

### ブランチ命名規則

- 新機能: `feature/説明` (例: `feature/add-auth`)
- バグ修正: `fix/説明` (例: `fix/login-bug`)
- リファクタ: `refactor/説明`
- ドキュメント: `docs/説明`
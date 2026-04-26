function cw --description "Create worktree and launch Claude Code"
    if test (count $argv) -eq 0
        echo "Usage: cw <task description or branch name>"
        return 1
    end

    set -l branch

    # `/` を含む場合はブランチ名として直接使用
    if string match -q '*/*' "$argv[1]"
        set branch $argv[1]
    else
        # Claude にブランチ名を生成させる
        set -l task (string join " " $argv)
        set branch (claude -p "Generate a git branch name for this task. Output only the branch name in format: feat/xxx, fix/xxx, refactor/xxx, chore/xxx, docs/xxx. No explanation. Task: $task")
        set branch (string trim $branch)
        if test -z "$branch"
            echo "Failed to generate branch name"
            return 1
        end
        echo "Branch: $branch"
        read -P "OK? [Y/n] " confirm
        if test "$confirm" = n -o "$confirm" = N
            return 1
        end
    end

    # スラッグ生成（/ → - に置換してフラットなディレクトリ名にする）
    set -l slug (string replace -a '/' '-' $branch)
    set -l repo_root (git rev-parse --show-toplevel)
    set -l wt_path "$repo_root/.wt/$slug"

    # 既存 worktree が同ブランチに存在する場合は再作成せず移動のみ
    if git worktree list | string match -q "*[$branch]*"
        cd $wt_path
        and claude
        return
    end

    # ワークツリー作成（ブランチ存在有無で分岐）
    mkdir -p "$repo_root/.wt"
    if git branch --list "$branch" | string match -qr '\S'
        # ローカルブランチが既に存在する
        git worktree add "$wt_path" "$branch"; or return 1
    else if git branch -r --list "origin/$branch" | string match -qr '\S'
        # リモートにのみ存在する → ローカルブランチを追跡付きで作成
        git worktree add "$wt_path" "$branch"; or return 1
    else
        # 新規ブランチ
        git worktree add -b "$branch" "$wt_path"; or return 1
    end

    # copyignored: .gitignore で無視されているがトラッキング外のファイルをコピー
    set -l ignored_files (git ls-files --ignored --exclude-standard --others)
    for f in $ignored_files
        set -l src "$repo_root/$f"
        set -l dst "$wt_path/$f"
        if test -f "$src"
            mkdir -p (dirname "$dst")
            cp "$src" "$dst"
        end
    end

    cd $wt_path
    and claude
end

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

    # ブランチの存在チェックで gwq add のフラグを決定（ローカル + リモート）
    if git branch --list "$branch" | string match -qr '\S'; or git branch -r --list "origin/$branch" | string match -qr '\S'
        gwq add "$branch"; or return 1
    else
        gwq add -b "$branch"; or return 1
    end

    # worktree パスを取得して移動
    set -l wt_path (git worktree list | grep -F "[$branch]" | awk '{print $1}')
    if test -z "$wt_path"
        echo "Failed to find worktree path for $branch"
        return 1
    end

    cd $wt_path
    and claude --allow-dangerously-skip-permissions
end

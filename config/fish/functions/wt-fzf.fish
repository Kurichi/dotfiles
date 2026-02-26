function wt-fzf --description "Select git-wt worktree with fzf and cd"
    set -l selected (git wt | tail -n +2 | awk '{print ($1 == "*" ? $2 : $1)}' | fzf --preview "eza --color=always --icons -la {}")
    if test -n "$selected"
        cd $selected
        commandline -f repaint
    end
end

function gwq-fzf --description "Select gwq worktree with fzf and cd"
    set -l selected (gwq list | fzf --preview "eza --color=always --icons -la {}")
    if test -n "$selected"
        cd $selected
        commandline -f repaint
    end
end

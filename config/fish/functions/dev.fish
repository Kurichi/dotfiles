function dev --description "Select ghq repository or gwq worktree with fzf and cd"
    set -l selected (ghq list --full-path | fzf --preview "eza --color=always --icons -la {}")
    if test -n "$selected"
        cd $selected
        commandline -f repaint
    end
end

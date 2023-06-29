if status is-interactive
    # Commands to run in interactive sessions can go here

    eval (/opt/homebrew/bin/brew shellenv)
end

fish_hybrid_key_bindings
bind -M insert -m default jk force-repaint
bind -M insert -m default jj force-repaint

set -gx PNPM_HOME "/Users/kurichi/Library/pnpm"

# git aliases
abbr -a gp 'git push origin HEAD'
abbr -a gc 'git commit'
abbr -a gs 'git switch'
abbr -a gsm 'git switch main'
abbr -a gsd 'git switch develop'
abbr -a gsc 'git switch -c '

# docker aliases
abbr -a dcom 'docker compose'

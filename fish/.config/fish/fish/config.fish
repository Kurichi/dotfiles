if status is-interactive
    # Commands to run in interactive sessions can go here

    eval (/opt/homebrew/bin/brew shellenv)
end

fish_hybrid_key_bindings
bind -M insert -m default jk force-repaint
bind -M insert -m default jj force-repaint

abbr -a gp 'git push origin HEAD'
abbr -a gs 'git switch'
abbr -a gdb 'git branch --merged | grep -v "\*" | grep -v main | xargs git branch -d'

abbr -a repo 'gh repo view --web'

abbr -a kube 'kubectl'
abbr -a k8s 'kubectl'

alias ls="eza"

# volta
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
# end volta

source /opt/homebrew/opt/asdf/libexec/asdf.fish

# pnpm
set -gx PNPM_HOME "/Users/kurichi/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end


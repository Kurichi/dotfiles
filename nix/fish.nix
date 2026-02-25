{ pkgs, ... }:

{
  # Fish functions from external files
  xdg.configFile = {
    "fish/functions/dev.fish".source = ../config/fish/functions/dev.fish;
    "fish/functions/ghq-fzf.fish".source = ../config/fish/functions/ghq-fzf.fish;
    "fish/functions/gwq-fzf.fish".source = ../config/fish/functions/gwq-fzf.fish;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""

      # Homebrew
      eval (/opt/homebrew/bin/brew shellenv)

      # asdf (prefer ASDF_DATA_DIR, fallback to default ~/.asdf)
      set -l asdf_shims ""
      if set -q ASDF_DATA_DIR; and test -d "$ASDF_DATA_DIR/shims"
        set asdf_shims "$ASDF_DATA_DIR/shims"
      else if test -d ~/.asdf/shims
        set asdf_shims ~/.asdf/shims
      end
      if test -n "$asdf_shims"
        fish_add_path --prepend "$asdf_shims"
      end

      # VSCode
      fish_add_path --append "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
      # pnpm
      fish_add_path --append $PNPM_HOME
      # go (equivalent to: export PATH="$(go env GOPATH)/bin:$PATH")
      if command -q go
        set -l gopath_bin (go env GOPATH)/bin
        if test -d "$gopath_bin"
          fish_add_path --prepend "$gopath_bin"
        end
      end

      # Key bindings
      fish_hybrid_key_bindings
      bind -M insert -m default jk force-repaint
      bind -M insert -m default jj force-repaint
    '';
    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      cat = "bat";
      g = "git";
    };
    shellAbbrs = {
      gp = "git push origin HEAD";
      gs = "git switch";
      gdb = "git branch --merged | grep -v \"*\" | grep -v main | xargs git branch -d";
      repo = "gh repo view --web";
      kube = "kubectl";
      k8s = "kubectl";
      # nix
      rebuild = "darwin-rebuild switch --flake ~/repos/dotfiles#ca";
      # claude
      claude = "claude --allow-dangerously-skip-permissions";
    };
    functions = {
      fish_prompt = ''
        # Cache exit status
        set -l last_status $status

        if not set -q __fish_prompt_char
          switch (id -u)
            case 0
              set -g __fish_prompt_char '#'
            case '*'
              set -g __fish_prompt_char '$'
          end
        end

        # Setup colors
        set -l hostcolor (set_color (uname -n | md5sum | cut -f1 -d' ' | tr -d '\n' | tail -c6))
        set -l normal (set_color normal)
        set -l white (set_color FFFFFF)
        set -l turquoise (set_color 5fdfff)
        set -l orange (set_color df5f00)
        set -l hotpink (set_color df005f)
        set -l blue (set_color blue)
        set -l cyan (set_color cyan)
        set -l limegreen (set_color 87ff00)
        set -l purple (set_color af5fff)

        set -l base_path (pwd)

        # Check if current directory is a git repository
        set -l git_dir ""
        if test -d .git; or git rev-parse --is-inside-work-tree >/dev/null 2>&1
          set -l parent_dir (dirname (git rev-parse --show-toplevel 2>/dev/null))
          set git_dir (echo $base_path|sed "s=$parent_dir/==")
          set base_path "$parent_dir/"
        end

        # Configure __fish_git_prompt
        set -g __fish_git_prompt_char_stateseparator ' '
        set -g __fish_git_prompt_color 5fdfff
        set -g __fish_git_prompt_color_flags df5f00
        set -g __fish_git_prompt_color_prefix white
        set -g __fish_git_prompt_color_suffix white
        set -g __fish_git_prompt_showdirtystate true
        set -g __fish_git_prompt_showuntrackedfiles true
        set -g __fish_git_prompt_showstashstate true
        set -g __fish_git_prompt_show_informative_status true

        # Line 1
        echo -n $cyan(echo $base_path|sed "s=$HOME=⌁=")$limegreen(echo $git_dir)$turquoise
        __fish_git_prompt " (%s)"
        echo

        # Line 2
        echo -n $hostcolor'    '

        # Disable virtualenv's default prompt
        set -g VIRTUAL_ENV_DISABLE_PROMPT true

        # support for virtual env name
        if set -q VIRTUAL_ENV
          echo -n "($turquoise"(basename "$VIRTUAL_ENV")"$white)"
        end

        # Rest of the prompt
        echo -n $hostcolor'─'$white$__fish_prompt_char $normal
      '';
    };
  };

  # fzf
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

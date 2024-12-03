function fish_prompt
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



  ##
  ## Line 1
  ##
  echo -n $cyan(echo $base_path|sed "s=$HOME=⌁=")$limegreen(echo $git_dir)$turquoise
  __fish_git_prompt " (%s)"
  echo

  ##
  ## Line 2
  ##
  echo -n $hostcolor'    '

  # Disable virtualenv's default prompt
  set -g VIRTUAL_ENV_DISABLE_PROMPT true

  # support for virtual env name
  if set -q VIRTUAL_ENV
    echo -n "($turquoise"(basename "$VIRTUAL_ENV")"$white)"
  end

  ##
  ## Rest of the prompt
  ##
  echo -n $hostcolor'─'$white$__fish_prompt_char $normal
end

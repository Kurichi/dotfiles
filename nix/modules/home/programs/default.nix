{ ... }:

{
  imports = [
    ./git.nix
    ./ssh.nix
    ./fish.nix
    ./fzf.nix
    ./direnv.nix
    ./neovim.nix
    ./vscode.nix
    ./wezterm.nix
    ./llm-agents.nix
  ];
}

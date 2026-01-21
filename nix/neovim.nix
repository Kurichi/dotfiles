{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # LSP Servers
      gopls
      lua-language-server
      llvmPackages.clang-tools # clangd
      dockerfile-language-server-nodejs
      docker-compose-language-service
      vscode-langservers-extracted # html, json, css
      marksman
      python312Packages.python-lsp-server
      yaml-language-server
      typescript-language-server
      typescript
      terraform-ls

      # Formatters / Linters
      stylua
      gotools # goimports
      golangci-lint
      terraform
    ];
  };

  # NeoVim config files
  # lazy-lock.json は書き込みが必要なので Nix 管理外
  xdg.configFile = {
    "nvim/init.lua".source = ../config/nvim/init.lua;
    "nvim/lua".source = ../config/nvim/lua;
    "nvim/spell".source = ../config/nvim/spell;
  };
}

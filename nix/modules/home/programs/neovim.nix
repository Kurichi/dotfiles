{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = [
      # LSP Servers
      pkgs.gopls
      pkgs.lua-language-server
      pkgs.llvmPackages.clang-tools # clangd
      pkgs.dockerfile-language-server
      pkgs.docker-compose-language-service
      pkgs.vscode-langservers-extracted # html, json, css
      pkgs.marksman
      pkgs.python312Packages.python-lsp-server
      pkgs.yaml-language-server
      pkgs.typescript-language-server
      pkgs.typescript
      pkgs.terraform-ls

      # Formatters / Linters
      pkgs.stylua
      pkgs.gotools # goimports
      pkgs.golangci-lint
      pkgs.terraform
    ];
  };

  # NeoVim config files
  # lazy-lock.json は書き込みが必要なので Nix 管理外
  xdg.configFile = {
    "nvim/init.lua".source = ../../../../config/nvim/init.lua;
    "nvim/lua".source = ../../../../config/nvim/lua;
    "nvim/spell".source = ../../../../config/nvim/spell;
  };
}

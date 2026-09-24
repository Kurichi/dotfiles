{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # config/nvim は Ruby/Python provider を使わないため、26.05 の新デフォルトを
    # 明示して stateVersion < 26.05 のデフォルト変更警告を解消する。
    # extraPackages の python-lsp-server は独立した LSP バイナリで provider とは無関係
    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      # LSP Servers
      gopls
      lua-language-server
      llvmPackages.clang-tools # clangd
      dockerfile-language-server
      docker-compose-language-service
      vscode-langservers-extracted # html, json, css
      marksman
      python312Packages.python-lsp-server
      yaml-language-server
      typescript-language-server
      typescript
      terraform-ls
      copilot-language-server

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
    "nvim/init.lua".source = ../../../../config/nvim/init.lua;
    "nvim/lua".source = ../../../../config/nvim/lua;
    "nvim/spell".source = ../../../../config/nvim/spell;
  };
}

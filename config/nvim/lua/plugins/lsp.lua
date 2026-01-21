return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("plugins/configs/lspconfig")
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("lsp_signature").setup()
      require("lsp_signature").on_attach()
    end,
  },
}

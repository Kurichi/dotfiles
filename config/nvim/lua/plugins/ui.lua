return {
  -- Lualine
  { "nvim-tree/nvim-web-devicons", opt = true },
  {
    "nvim-lualine/lualine.nvim",
    event = { "BufNewFile", "BufRead" },
    options = { theme = "gruvbox" },
    config = true,
  },

  -- Start Screen
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  },

  -- Theme
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
        },
      })

      vim.cmd("colorscheme catppuccin-frappe")
    end,
  },
}

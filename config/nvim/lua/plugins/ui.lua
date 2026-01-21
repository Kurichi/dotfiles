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
    event = "VimEnter",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
        },
      })

      vim.cmd("colorscheme catppuccin-frappe")

      vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NonText", { bg = "none", ctermbg = "none" })
    end,
  },
}

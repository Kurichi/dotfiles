return {
  { "nvim-telescope/telescope-ui-select.nvim", lazy = true },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    lazy = true,
    build = "make",
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-telescope/telescope-file-browser.nvim", lazy = true },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<Leader>ff", mode = "n" },
      { "<Leader>fb", mode = "n" },
      { "<Leader>fg", mode = "n" },
    },
    config = function()
      require("plugins/configs/telescope")
    end,
  },
}

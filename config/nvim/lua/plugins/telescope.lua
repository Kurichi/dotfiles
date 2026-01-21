return {
  { "nvim-telescope/telescope-ui-select.nvim",   lazy = false },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope-file-browser.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    event = { "BufWinEnter" },
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

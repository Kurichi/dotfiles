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
  { "nvim-telescope/telescope-live-grep-args.nvim", lazy = true },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<Leader>ff", function() require("telescope.builtin").find_files() end, mode = "n" },
      { "<Leader>fg", function() require("telescope").extensions.live_grep_args.live_grep_args() end, mode = "n" },
      { "<Leader>fb", function() require("telescope.builtin").buffers() end, mode = "n" },
      { "<Leader>fd", function() require("telescope.builtin").diagnostics() end, mode = "n" },
      { "<Leader>fs", function() require("telescope.builtin").treesitter() end, mode = { "n", "v" } },
      { "gd", function() require("telescope.builtin").lsp_definitions() end, mode = "n" },
      { "gi", function() require("telescope.builtin").lsp_implementations() end, mode = "n" },
      { "gr", function() require("telescope.builtin").lsp_references() end, mode = "n" },
      { "gt", function() require("telescope.builtin").lsp_type_definitions() end, mode = "n" },
    },
    config = function()
      require("plugins/configs/telescope")
    end,
  },
}

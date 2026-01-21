return {
  { "kkharji/sqlite.lua", module = "sqlite" },
  {
    "AckslD/nvim-neoclip.lua",
    keys = {
      { "<leader>p", desc = "Paste from neoclip", mode = "n" },
    },
    config = function()
      require("neoclip").setup()

      vim.keymap.set("n", "<leader>p", "<cmd>Telescope neoclip<CR>", { noremap = true, silent = true })
    end,
  },
}

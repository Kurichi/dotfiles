return {
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua" },
    keys = {
      { "<leader>p", desc = "Paste from neoclip", mode = "n" },
    },
    config = function()
      require("neoclip").setup()

      vim.keymap.set("n", "<leader>p", "<cmd>Telescope neoclip<CR>", { noremap = true, silent = true })
    end,
  },
}

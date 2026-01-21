return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { "<Leader>t" },
    config = function()
      require("toggleterm").setup()

      vim.keymap.set("n", "<Leader>t", function()
        vim.cmd("ToggleTerm direction=float")
      end, { noremap = true, silent = true })
      vim.keymap.set("t", "<C-t>", function()
        vim.cmd("ToggleTerm")
      end, { noremap = true, silent = true })
    end,
  },
}

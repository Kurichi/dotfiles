return {
  { "nvim-tree/nvim-web-devicons" },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    config = function()
      vim.api.nvim_set_var("loaded_netrw", 1)
      vim.api.nvim_set_var("loaded_netrwPlugin", 1)

      require("nvim-tree").setup({
        sort_by = "extension",
        disable_netrw = true,

        view = {
          width = "18%",
        },
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
      })

      -- キーマッピングを設定
      vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { noremap = true, silent = true })
    end,
  },
}

local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
      n = {
        ["<Esc>"] = actions.close,
      },
    },
    file_ignore_patterns = {
      -- 検索から除外するものを指定
      "^.git/",
      "^.cache/",
    },
    vimgrep_arguments = {
      -- ripggrepコマンドのオプション
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "-uu",
    },
  },
  extensions = {
    -- ソート性能を大幅に向上させるfzfを使う
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
    file_browser = {},
    live_grep_args = {
      auto_quoting = true,
      mappings = {
        i = {
          ["<C-g>"] = require("telescope-live-grep-args.actions").quote_prompt(),
        },
      },
    },
  },
})
telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("file_browser")
telescope.load_extension("live_grep_args")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", telescope.extensions.live_grep_args.live_grep_args)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fd", builtin.diagnostics)
vim.keymap.set("n", "<leader>fs", builtin.treesitter)
vim.keymap.set("v", "<leader>fs", builtin.treesitter)
vim.keymap.set("n", "gd", builtin.lsp_references)
vim.keymap.set("n", "<leader>b", "<C-o>")

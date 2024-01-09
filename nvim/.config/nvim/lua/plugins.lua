return {
  -- VimDoc (Japanese Vim Help)
  { 
    'vim-jp/vimdoc-ja',
    lazy = true,
    keys = {
      { "h", mode = "c", },
    },
  },

  -- Nvimtree (File Explorer)
  {
    'nvim-tree/nvim-tree.lua',
    lazy = false,
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    config = function() require 'plugin/nvim-tree' end,
  },

  -- Lualine (Statusline)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-web-devicons', opt = true },
    event = { 'BufNewFile', 'BufRead' },
    options = { theme = 'gruvbox' },
    config = 'require("lualine").setup()'
  },

  -- Nvim TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- disable rtp plugin, as we only need its queries for mini.ai
          -- In case other textobject modules are enabled, we will load them
          -- once nvim-treesitter is loaded
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          load_textobjects = true
        end,
      },
    },
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        highlight = {
          enable = true,
          --[[ disable = { "embedded_template" } ]]
        },
        indent = {
          enable = true
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        matchup = {
          enable = true
        }
      }
    end,
    cmd = { "TSUpdateSync" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    }
  },

  -- LSP
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },

      {
        'williamboman/mason.nvim',
        cmd = {
          "Mason",
          "MasonInstall",
          "MasonUninstall",
          "MasonUninstallAll",
          "MasonLog",
          "MasonUpdate",
        },
        build = ":MasonUpdate",
      },

      {
        'williamboman/mason-lspconfig.nvim',
        event = { "BufReadPre", "BufNewFile" },
      },
      -- Autocompletion
      {
        'hrsh7th/nvim-cmp',
        event = "InsertEnter",
      },         -- Required
      {'hrsh7th/cmp-nvim-lsp'},     -- Required
      {'hrsh7th/cmp-buffer'},       -- Optional
      {'hrsh7th/cmp-path'},         -- Optional
      {'saadparwaiz1/cmp_luasnip'}, -- Optional
      {'hrsh7th/cmp-nvim-lua'},     -- Optional
      -- Snippets
      {'L3MON4D3/LuaSnip'},             -- Required
      {'rafamadriz/friendly-snippets'}, -- Optional
    },
    config = function() require 'plugin/lsp' end,
  },

  -- Comment
  {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },

  {
    'github/copilot.vim',
    lazy = false,
    config = function() require 'plugin/copilot' end,
  },

  {
    'kevinhwang91/nvim-hlslens',
    lazy = true,
    keys = {
      { '/', mode='n' },
      { '*', mode='n' },
      { '#', mode='n' },
      { 'g*', mode='n' },
      { 'g#', mode='n' },
      { 'g/', mode='n' },
    }
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    config = function() require 'plugin/telescope' end,
    dependencies = {
      {'nvim-tree/nvim-web-devicons'}, 
      {'nvim-lua/plenary.nvim'},
    },
    keys = {
      { '<Leader>ff', mode='n' },
    }
  },
}


return {
  -- Lualine
  { "nvim-tree/nvim-web-devicons" },
  {
    "nvim-lualine/lualine.nvim",
    event = { "BufNewFile", "BufRead" },
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
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          gitsigns = true,
          nvimtree = true,
        },
      })

      vim.cmd("colorscheme catppuccin-frappe")

      -- 補完メニューは transparent_background の対象から外す。
      -- 透けると本文と重なって読めないため、背景を明示的に塗る
      local function completion_hl()
        local ok, palettes = pcall(require, "catppuccin.palettes")
        if not ok then
          return
        end
        local c = palettes.get_palette("frappe")
        local hl = vim.api.nvim_set_hl
        hl(0, "Pmenu", { fg = c.text, bg = c.mantle })
        hl(0, "PmenuSel", { fg = c.text, bg = c.surface1, bold = true })
        hl(0, "PmenuKind", { fg = c.overlay1, bg = c.mantle })
        hl(0, "PmenuKindSel", { fg = c.overlay1, bg = c.surface1 })
        hl(0, "PmenuExtra", { fg = c.overlay0, bg = c.mantle })
        hl(0, "PmenuExtraSel", { fg = c.overlay0, bg = c.surface1 })
        hl(0, "PmenuMatch", { fg = c.blue, bg = c.mantle, bold = true })
        hl(0, "PmenuMatchSel", { fg = c.blue, bg = c.surface1, bold = true })
        hl(0, "PmenuSbar", { bg = c.surface0 })
        hl(0, "PmenuThumb", { bg = c.overlay0 })
        hl(0, "PmenuBorder", { fg = c.surface2, bg = c.mantle })
        -- Copilot のゴーストテキスト
        hl(0, "ComplHint", { fg = c.overlay0, italic = true })
        hl(0, "ComplHintMore", { fg = c.overlay0, italic = true })

        -- 種別ごとの色。lspconfig.lua の convert が CmpItemKind<種別> を割り当てる
        local by_kind = {
          Text = c.teal,
          Method = c.blue,
          Function = c.blue,
          Constructor = c.sapphire,
          Field = c.teal,
          Variable = c.peach,
          Class = c.yellow,
          Interface = c.yellow,
          Module = c.pink,
          Property = c.teal,
          Unit = c.green,
          Value = c.peach,
          Enum = c.yellow,
          Keyword = c.mauve,
          Snippet = c.flamingo,
          Color = c.rosewater,
          File = c.blue,
          Reference = c.red,
          Folder = c.blue,
          EnumMember = c.teal,
          Constant = c.peach,
          Struct = c.yellow,
          Event = c.peach,
          Operator = c.sky,
          TypeParameter = c.maroon,
          Unknown = c.overlay1,
        }
        for kind, color in pairs(by_kind) do
          hl(0, "CmpItemKind" .. kind, { fg = color, bg = c.mantle })
          hl(0, "CmpItemKind" .. kind .. "Sel", { fg = color, bg = c.surface1 })
        end
      end

      completion_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("CompletionHighlights", {}),
        callback = completion_hl,
      })
    end,
  },
}

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
    { name = "luasnip" },
    { name = "copilot" },
    {
      name = "spell",
      option = {
        keep_all_entries = false,
        enable_in_context = function()
          return true
        end,
        preselect_correct_word = true,
      },
    },
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<Tab>"] = cmp.mapping.confirm({ select = false }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = "select" }),
    ["<C-p>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item({ behavior = "insert" })
      else
        cmp.complete()
      end
    end),
    ["<C-n>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item({ behavior = "insert" })
      else
        cmp.complete()
      end
    end),
  },
  completion = { completeopt = "menu,menuone,noinsert" },
  preselect = cmp.PreselectMode.Item,
})

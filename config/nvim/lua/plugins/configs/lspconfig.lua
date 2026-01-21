-- TODO: nvim-lspconfig v3.0.0 で require('lspconfig') が非推奨になる
-- vim.lsp.config を使用するように移行が必要 (:help lspconfig-nvim-0.11)
local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- デフォルト設定のLSP
local servers = {
  "clangd",
  "dockerls",
  "docker_compose_language_service",
  "html",
  "jsonls",
  "marksman",
  "pylsp",
  "yamlls",
  "ts_ls",
  "terraformls",
  "lua_ls",
}

for _, server in ipairs(servers) do
  lspconfig[server].setup({ capabilities = capabilities })
end

-- gopls: カスタム設定
lspconfig.gopls.setup({
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = { unusedparams = true },
    },
    staticcheck = true,
    gofumpt = true,
  },
})

-- nvim-lspconfig v3.0.0+ / Neovim 0.11+ の vim.lsp.config API を使用

-- cmp-nvim-lsp の capabilities を設定
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- グローバル設定（全LSPに適用）
vim.lsp.config("*", {
	capabilities = capabilities,
})

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
	vim.lsp.enable(server)
end

-- gopls: カスタム設定
vim.lsp.config("gopls", {
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
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
vim.lsp.enable("gopls")

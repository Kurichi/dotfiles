-- nvim-lspconfig v3.0.0+ / Neovim 0.11+ の vim.lsp.config API を使用
-- capabilities は make_client_capabilities() が snippetSupport / resolveSupport /
-- inlineCompletion を既に含むため明示設定は不要

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
			staticcheck = true,
			gofumpt = true,
		},
	},
})
vim.lsp.enable("gopls")

-- 組み込み補完を LSP バッファで有効化。
-- 自動発火は 'autocomplete' + 'complete' の "o"(omnifunc) が担うので autotrigger は付けない。
-- 両方有効にすると 2 つの機構が互いに再トリガーし、候補が勝手に挿入される。
-- ここでの enable は CompleteDone 経由の auto-import / スニペット展開を有効にするために必要。
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspCompletion", {}),
	callback = function(args)
		vim.lsp.completion.enable(true, args.data.client_id, args.buf)
	end,
})

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

-- Copilot: 設定は nvim-lspconfig の lsp/copilot.lua をそのまま使う
-- (:LspCopilotSignIn / :LspCopilotSignOut もそこで定義される)。
-- 提案はゴーストテキストで出し、<C-f> で採用する (keymaps.lua)
vim.lsp.enable("copilot")
vim.lsp.inline_completion.enable()

-- 組み込み補完を LSP バッファで有効化。
-- 'complete' から omnifunc(o) を外したので、LSP の発火はここの autotrigger が担う。
-- (o と autotrigger を併用すると 2 つの機構が互いに再トリガーし合って壊れる)
--
-- 組み込みの LSP 補完は kind_hlgroup を Color 種別にしか設定しないため、
-- 種別カラムが PmenuKind 一色になる。convert でアイテムごとに差し替える
-- (convert の戻り値は tbl_extend('keep', ...) で優先される)
local kind_hl = setmetatable({}, {
	__index = function(_, kind)
		return "CmpItemKind" .. (kind or "Unknown")
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspCompletion", {}),
	callback = function(args)
		vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
			autotrigger = true,
			convert = function(item)
				local kind = vim.lsp.protocol.CompletionItemKind[item.kind]
				return { kind_hlgroup = kind_hl[kind] }
			end,
		})
	end,
})

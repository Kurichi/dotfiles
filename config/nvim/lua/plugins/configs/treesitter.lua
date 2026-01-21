-- nvim-treesitter configuration for Neovim 0.11+
local parsers = {
	"bash",
	"css",
	"dockerfile",
	"go",
	"gomod",
	"html",
	"javascript",
	"json",
	"lua",
	"python",
	"rust",
	"toml",
	"typescript",
	"yaml",
	"markdown",
}

-- Install parsers
require("nvim-treesitter").install(parsers)

-- Enable treesitter features via FileType autocmd
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.bo[buf].filetype
		if ft == "" then
			return
		end

		-- Check if parser exists for this filetype
		local ok = pcall(vim.treesitter.get_parser, buf)
		if not ok then
			return
		end

		-- Enable highlighting
		vim.treesitter.start(buf)

		-- Enable folding
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo.foldenable = false

		-- Enable indentation
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

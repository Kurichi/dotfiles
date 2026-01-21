local options = {
	-- indent
	tabstop = 2,
	shiftwidth = 2,
	expandtab = true,
	smartindent = true,
	autoindent = true,
}

return function()
	for k, v in pairs(options) do
		vim.bo[k] = v
	end
end

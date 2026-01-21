local options = {
	-- indent
	tabstop = 4,
	shiftwidth = 4,
	expandtab = false,
	smartindent = true,
	autoindent = true,
}

return function()
	for k, v in pairs(options) do
		vim.bo[k] = v
	end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local filetype = vim.bo.filetype
    local success, settings = pcall(require, 'lang.' .. filetype)
    if success then
      settings()
    end
  end,
})
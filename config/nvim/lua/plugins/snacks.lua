return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>gy",
      function()
        require("snacks").gitbrowse({
          what = "permalink",
          notify = false,
          open = function(url)
            vim.fn.setreg("+", url)
            vim.notify("Copied: " .. url)
          end,
        })
      end,
      mode = { "n", "x" },
      desc = "Copy git permalink",
    },
    {
      "<leader>gY",
      function() require("snacks").gitbrowse({ what = "permalink" }) end,
      mode = { "n", "x" },
      desc = "Open git permalink in browser",
    },
  },
}

return {
  "smoka7/hop.nvim",
  version = "*",
  event = { "BufRead", "BufNewFile" },
  config = function() 
    local hop = require("hop")
     
    hop.setup {
      keys = "weruiopasdfghjkl;"
    }
    
    local directions = require("hop.hint").HintDirection
    -- f,t を変更
    vim.keymap.set("", "f", function()
      hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
    end, {remap=true})
    vim.keymap.set("", "F", function()
      hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
    end, {remap=true})
    vim.keymap.set("", "t", function()
      hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
    end, {remap=true})
    vim.keymap.set("", "T", function()
      hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
    end, {remap=true})

    vim.keymap.set("", "<Leader><Leader>s", function()
      hop.hint_char1({})
    end, {remap=true})
    vim.keymap.set("", "<Leader><Leader>/", function()
      hop.hint_patterns({})
    end, {remap=true})
  end,
}

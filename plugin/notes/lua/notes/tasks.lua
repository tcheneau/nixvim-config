local M = {}

-- Toggle checkbox state on the current line
-- - [ ] → - [x] → - [ ]
function M.toggle()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- Match checkbox patterns: - [ ], - [x], - [X], * [ ], etc.
  local unchecked = line:match("^(%s*[-*+]%s+%[%)%s)")
  local checked = line:match("^(%s*[-*+]%s+%[[xX]%])")

  if line:match("%[%s%]") then
    -- [ ] → [x]
    local new_line = line:gsub("%[%s%]", "[x]", 1)
    vim.api.nvim_set_current_line(new_line)
    vim.notify("Task done", vim.log.levels.INFO)
  elseif line:match("%[[xX]%]") then
    -- [x] → [ ]
    local new_line = line:gsub("%[[xX]%]", "[ ]", 1)
    vim.api.nvim_set_current_line(new_line)
    vim.notify("Task undone", vim.log.levels.INFO)
  else
    -- No checkbox on this line, add one
    local new_line = line:gsub("^(%s*[-*+]%s+)", "%1[ ] ", 1)
    if new_line ~= line then
      vim.api.nvim_set_current_line(new_line)
    else
      -- Not a list item, just notify
      vim.notify("No list item or checkbox on this line", vim.log.levels.WARN)
    end
  end
end

return M
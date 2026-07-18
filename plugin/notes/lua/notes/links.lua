local M = {}

--- Extract the [[Page Name]] link under the cursor
local function get_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

  -- Find all [[...]] on the line and check which contains the cursor
  local start = 1
  while true do
    local s, e, match = line:find("%[%[(.-)%]%]", start)
    if not s then break end
    if col >= s and col <= e then
      return match
    end
    start = e + 1
  end
  return nil
end

--- Follow the wiki link under the cursor
function M.follow(config)
  local link = get_link_under_cursor()
  if not link then
    vim.notify("No [[link]] under cursor", vim.log.levels.WARN)
    return
  end

  local utils = require("notes.utils")
  utils.open_page(config, link)
end

--- Prompt for a new page name and create it
function M.new_page(config)
  vim.ui.input({ prompt = "New page name: " }, function(name)
    if not name or name == "" then return end
    local utils = require("notes.utils")
    utils.open_page(config, name)
    vim.notify("Created: " .. name, vim.log.levels.INFO)
  end)
end

return M
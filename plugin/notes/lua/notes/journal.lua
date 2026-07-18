local M = {}

local function today_date()
  return os.date("%Y-%m-%d")
end

function M.open_today(config)
  local date = today_date()
  local path = config.journal_dir .. "/" .. date .. ".md"

  -- Create from journal template if it doesn't exist
  if vim.fn.filereadable(path) == 0 and config.journal_template then
    local content = require("notes.templates").load_and_apply(config, config.journal_template, {
      title = date,
      page = date,
      date = date,
      weekday = os.date("%A"),
    })
    if content then
      vim.fn.writefile(vim.split(content, "\n"), path)
    end
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

return M
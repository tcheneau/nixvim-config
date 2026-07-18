local M = {}

--- Show backlinks for the current page using Telescope
function M.show(config)
  local utils = require("notes.utils")
  local page_name = utils.get_current_page_name(config)
  if not page_name then
    vim.notify("Not a notes buffer", vim.log.levels.WARN)
    return
  end

  -- Search for [[PageName]] across all notes
  local search_pattern = "\\[\\[" .. vim.pesc(page_name) .. "\\]\\]"
  require("telescope.builtin").live_grep({
    cwd = config.notes_dir,
    prompt_title = "Backlinks to: " .. page_name,
    default_text = "[[" .. page_name .. "]]",
  })
end

return M
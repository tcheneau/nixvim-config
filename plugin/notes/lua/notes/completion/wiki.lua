-- blink-cmp source for [[wiki link]] completion
local M = {}

function M.get_completions(ctx, callback)
  local config = require("notes").config
  if not config then return callback({ items = {} }) end

  local utils = require("notes.utils")
  if not utils.is_notes_buffer(config) then
    return callback({ items = {} })
  end

  -- Check if we're inside [[... (no closing ]])
  local before = ctx.line:sub(1, ctx.cursor[2])
  local link_start = before:match("%[%[([^%]]*)$")
  if not link_start then
    return callback({ items = {} })
  end

  -- Get all page names and filter
  local pages = utils.get_pages(config)
  local items = {}

  for _, page in ipairs(pages) do
    if page:lower():match(link_start:lower()) or link_start == "" then
      table.insert(items, {
        label = page,
        kind = require("blink.cmp.types").CompletionItemKind.Reference,
        insertText = page .. "]]",
        documentation = { kind = "markdown", value = "Link to page: " .. page },
      })
    end
  end

  callback({ items = items })
  return function() end
end

return M
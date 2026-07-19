-- blink-cmp source for [[wiki link]] completion
local M = {}

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  self.opts = opts or {}
  return self
end

function M:get_trigger_characters()
  return { "[" }
end

function M:enabled()
  local config = require("notes").config
  if not config then return false end
  local utils = require("notes.utils")
  return utils.is_notes_buffer(config)
end

function M:get_completions(context, callback)
  local config = require("notes").config
  if not config then
    callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
    return function() end
  end

  local utils = require("notes.utils")
  if not utils.is_notes_buffer(config) then
    callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
    return function() end
  end

  -- Check if we're inside [[... (no closing ]])
  local before = context.line:sub(1, context.cursor[2])
  local link_start = before:match("%[%[([^%]]*)$")
  if not link_start then
    callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
    return function() end
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

  callback({ items = items, is_incomplete_forward = true, is_incomplete_backward = true })
  return function() end
end

return M
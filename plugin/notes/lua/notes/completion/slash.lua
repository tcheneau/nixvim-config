-- blink-cmp source for /slash commands in notes buffers
local M = {}

local slash_commands = {
  {
    label = "todo",
    insert = "- [ ] ",
    desc = "Insert unchecked task",
  },
  {
    label = "done",
    insert = "- [x] ",
    desc = "Insert checked task",
  },
  {
    label = "date",
    insert = os.date("%Y-%m-%d"),
    desc = "Insert today's date",
  },
  {
    label = "time",
    insert = os.date("%H:%M"),
    desc = "Insert current time",
  },
  {
    label = "weekday",
    insert = os.date("%A"),
    desc = "Insert day of the week",
  },
  {
    label = "journal",
    insert = nil,
    desc = "Open today's journal",
    action = "journal",
  },
  {
    label = "template",
    insert = nil,
    desc = "Insert a template (pick from list)",
    action = "template",
  },
  {
    label = "table",
    insert = nil,
    desc = "Create a markdown table",
    action = "table",
  },
}

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  self.opts = opts or {}
  return self
end

function M:get_trigger_characters()
  return { "/" }
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

  -- Check if line starts with / (possibly after whitespace or list marker)
  local line = context.line
  local col = context.cursor[2]
  local before = line:sub(1, col)

  -- Match / at start of line, after whitespace, or after "- "
  local slash_pos = before:match("^()%/") or before:match("^%s*()%/") or before:match("^%s*[-*+]%s+()%/")
  if not slash_pos then
    callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
    return function() end
  end

  -- Get the text after / for filtering
  local typed = before:sub(slash_pos + 1)
  local cursor_line = context.cursor[1] - 1 -- 0-indexed

  local items = {}
  for _, cmd in ipairs(slash_commands) do
    if cmd.label:lower():match(typed:lower()) or typed == "" then
      local item = {
        label = "/" .. cmd.label,
        kind = require("blink.cmp.types").CompletionItemKind.Snippet,
        filterText = cmd.label,
        documentation = { kind = "markdown", value = cmd.desc },
      }

      if cmd.insert then
        -- Replace /command with the insert text
        item.textEdit = {
          range = {
            start = { line = cursor_line, character = slash_pos - 1 },
            ["end"] = { line = cursor_line, character = col },
          },
          newText = cmd.insert,
        }
      elseif cmd.action then
        -- Clear the /command text, then execute the action via execute()
        item.textEdit = {
          range = {
            start = { line = cursor_line, character = slash_pos - 1 },
            ["end"] = { line = cursor_line, character = col },
          },
          newText = "",
        }
        item.data = { action = cmd.action }
      end

      table.insert(items, item)
    end
  end

  callback({ items = items, is_incomplete_forward = true, is_incomplete_backward = true })
  return function() end
end

--- Handle special actions (journal, template, table) after accepting a completion
function M:execute(context, item, resolve, default_implementation)
  if item.data and item.data.action then
    -- Apply the textEdit first (clears the /command text)
    default_implementation()
    -- Schedule the action for after the text edit is applied
    vim.schedule(function()
      local action = item.data.action
      if action == "journal" then
        vim.cmd("NotesJournal")
      elseif action == "template" then
        vim.cmd("NotesTemplate")
      elseif action == "table" then
        require("notes.table").create(require("notes").config)
      end
    end)
  else
    default_implementation()
  end
  resolve(item)
end

return M
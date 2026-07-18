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
    insert = nil, -- handled specially
    desc = "Open today's journal",
  },
  {
    label = "template",
    insert = nil, -- handled specially
    desc = "Insert a template (pick from list)",
  },
}

function M.get_completions(ctx, callback)
  local config = require("notes").config
  if not config then return callback({ items = {} }) end

  local utils = require("notes.utils")
  if not utils.is_notes_buffer(config) then
    return callback({ items = {} })
  end

  -- Check if line starts with / (possibly after whitespace or list marker)
  local line = ctx.line
  local col = ctx.cursor[2]
  local before = line:sub(1, col)

  -- Match / at start of line, after whitespace, or after "- "
  local slash_pos = before:match("^()%/") or before:match("^%s*()%/") or before:match("^%s*[-*+]%s+()%/")
  if not slash_pos then
    return callback({ items = {} })
  end

  -- Get the text after / for filtering
  local typed = before:sub(slash_pos + 1)

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
        -- Use textEdit to replace from / to cursor with the insert text
        item.textEdit = {
          range = {
            start = { line = ctx.cursor[1] - 1, character = slash_pos - 1 },
            ["end"] = { line = ctx.cursor[1] - 1, character = col },
          },
          newText = cmd.insert,
        }
      elseif cmd.label == "journal" then
        -- Special: open journal instead of inserting text
        item.textEdit = {
          range = {
            start = { line = ctx.cursor[1] - 1, character = slash_pos - 1 },
            ["end"] = { line = ctx.cursor[1] - 1, character = col },
          },
          newText = "",
        }
        item.command = {
          command = "NotesJournal",
        }
      elseif cmd.label == "template" then
        -- Special: open template picker
        item.textEdit = {
          range = {
            start = { line = ctx.cursor[1] - 1, character = slash_pos - 1 },
            ["end"] = { line = ctx.cursor[1] - 1, character = col },
          },
          newText = "",
        }
        item.command = {
          command = "NotesTemplate",
        }
      end

      table.insert(items, item)
    end
  end

  callback({ items = items })
  return function() end
end

return M
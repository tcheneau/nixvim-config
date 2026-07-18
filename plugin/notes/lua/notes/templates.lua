local M = {}

--- List available template names (filenames without .md extension)
function M.list(config)
  local templates = {}
  local files = vim.fn.split(vim.fn.globpath(config.templates_dir, "*.md"), "\n")
  for _, file in ipairs(files) do
    if file ~= "" then
      local name = vim.fn.fnamemodify(file, ":t:r")
      table.insert(templates, name)
    end
  end
  return templates
end

--- Load a template file and return its raw content
function M.load(config, name)
  local path = config.templates_dir .. "/" .. name .. ".md"
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(path)
  return table.concat(lines, "\n")
end

--- Substitute template variables
-- Variables: {{date}}, {{time}}, {{datetime}}, {{title}}, {{page}}, {{weekday}}, {{cursor}}
function M.apply(content, vars)
  vars = vars or {}
  local substitutions = {
    date = vars.date or os.date("%Y-%m-%d"),
    time = vars.time or os.date("%H:%M"),
    datetime = vars.datetime or os.date("%Y-%m-%d %H:%M"),
    title = vars.title or "",
    page = vars.page or vars.title or "",
    weekday = vars.weekday or os.date("%A"),
  }

  local result = content
  for key, value in pairs(substitutions) do
    result = result:gsub("{{" .. key .. "}}", value)
  end

  return result
end

--- Load and apply a template in one step
function M.load_and_apply(config, name, vars)
  local content = M.load(config, name)
  if not content then return nil end
  return M.apply(content, vars)
end

--- Insert a template at the current cursor position
function M.insert(config, name)
  if not name or name == "" then
    -- Use Telescope to pick a template
    local templates = M.list(config)
    if #templates == 0 then
      vim.notify("No templates found in " .. config.templates_dir, vim.log.levels.WARN)
      return
    end
    require("telescope.pickers").new({}, {
      prompt_title = "Notes: Select Template",
      finder = require("telescope.finders").new_table({ results = templates }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(bufnr, map)
        map("i", "<CR>", function()
          local selection = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(bufnr)
          if selection then
            M.insert(config, selection[1])
          end
        end)
        return true
      end,
    }):find()
    return
  end

  local utils = require("notes.utils")
  local page_name = utils.get_current_page_name(config)
  local content = M.load_and_apply(config, name, {
    title = page_name or "",
    page = page_name or "",
  })

  if not content then
    vim.notify("Template not found: " .. name, vim.log.levels.WARN)
    return
  end

  -- Handle {{cursor}} marker
  local cursor_pos = content:find("{{cursor}}")
  if cursor_pos then
    content = content:gsub("{{cursor}}", "")
  end

  -- Insert at cursor
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)

  -- Position cursor at {{cursor}} marker if present
  if cursor_pos then
    -- Count lines before the cursor marker
    local before = content:sub(1, cursor_pos - 1)
    local line_count = select(2, before:gsub("\n", "\n"))
    local last_line = before:match("([^\n]*)$") or ""
    vim.api.nvim_win_set_cursor(0, { row + line_count + 1, #last_line })
  end

  vim.notify("Template inserted: " .. name, vim.log.levels.INFO)
end

return M
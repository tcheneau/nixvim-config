local M = {}

--- Get list of all page names (filename without .md extension)
function M.get_pages(config)
  local pages = {}
  local files = vim.fn.split(vim.fn.globpath(config.pages_dir, "**/*.md"), "\n")
  for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ":r")
    name = name:gsub("^" .. vim.pesc(config.pages_dir .. "/"), "")
    table.insert(pages, name)
  end
  -- Also include journal entries
  local journals = vim.fn.split(vim.fn.globpath(config.journal_dir, "*.md"), "\n")
  for _, file in ipairs(journals) do
    local name = vim.fn.fnamemodify(file, ":r")
    name = name:gsub("^" .. vim.pesc(config.journal_dir .. "/"), "")
    table.insert(pages, name)
  end
  return pages
end

--- Get the page name of the current buffer
function M.get_current_page_name(config)
  local file = vim.fn.expand("%:p")
  if file == "" then return nil end

  local name = vim.fn.fnamemodify(file, ":r")
  for _, dir in ipairs({ config.pages_dir, config.journal_dir, config.notes_dir }) do
    local prefix = dir .. "/"
    if name:match("^" .. vim.pesc(prefix)) then
      return name:gsub("^" .. vim.pesc(prefix), "")
    end
  end
  return nil
end

--- Check if the current buffer is inside the notes directory
function M.is_notes_buffer(config)
  local file = vim.fn.expand("%:p")
  if file == "" then return false end
  return file:match("^" .. vim.pesc(config.notes_dir)) ~= nil
end

--- Get the full path for a page name
function M.page_path(config, name)
  -- Journal dates (YYYY-MM-DD) go in journal dir
  if name:match("^%d%d%d%d%-%d%d%-%d%d$") then
    return config.journal_dir .. "/" .. name .. ".md"
  end
  -- Namespaced pages use directory structure
  return config.pages_dir .. "/" .. name .. ".md"
end

--- Open a page by name, creating it if it doesn't exist
function M.open_page(config, name)
  local path = M.page_path(config, name)
  -- Create parent directories for namespaced pages
  local parent = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(parent, "p")
  -- Create file from template if it doesn't exist
  if vim.fn.filereadable(path) == 0 and config.default_template then
    local content = require("notes.templates").load_and_apply(config, config.default_template, {
      title = name,
      page = name,
    })
    if content then
      vim.fn.writefile(vim.split(content, "\n"), path)
    end
  end
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

return M
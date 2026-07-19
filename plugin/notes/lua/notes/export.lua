local M = {}

--- Get the system's "open" command for opening files in browser
local function get_opener()
  if vim.fn.has("mac") == 1 then return "open" end
  if vim.fn.executable("xdg-open") == 1 then return "xdg-open" end
  if vim.fn.executable("wslview") == 1 then return "wslview" end
  return nil
end

--- Export the current buffer to HTML or PDF using pandoc
--- Output is placed next to the source file
function M.export(config, format)
  if not format or format == "" then format = "html" end
  local file = vim.fn.expand("%:p")

  if file == "" or vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end

  local output = file:gsub("%.md$", "." .. format)
  local cmd = { "pandoc", file, "-o", output, "-s" }

  if format == "pdf" then
    table.insert(cmd, "--pdf-engine=xelatex")
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Exported to " .. output, vim.log.levels.INFO)
      else
        vim.notify("Export failed (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

--- Export the current buffer to a temp directory and open in browser
function M.export_and_open(config, format)
  if not format or format == "" then format = "html" end
  local file = vim.fn.expand("%:p")

  if file == "" or vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end

  local opener = get_opener()
  if not opener then
    vim.notify("No browser opener found (xdg-open/open/wslview)", vim.log.levels.ERROR)
    return
  end

  -- Export to a temp file
  local tmp = os.tmpname() .. "." .. format
  local title = vim.fn.fnamemodify(file, ":t:r")
  local cmd = { "pandoc", file, "-o", tmp, "-s", "--metadata", "title=" .. title }

  if format == "pdf" then
    table.insert(cmd, "--pdf-engine=xelatex")
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.fn.jobstart(opener .. " " .. vim.fn.shellescape(tmp))
        vim.notify("Opened in browser", vim.log.levels.INFO)
      else
        vim.notify("Export failed (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

return M
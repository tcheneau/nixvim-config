local M = {}

--- Export the current buffer to HTML or PDF using pandoc
function M.export(config, format)
  format = format or "html"
  local file = vim.fn.expand("%:p")

  if file == "" or vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end

  local output = file:gsub("%.md$", "." .. format)
  local cmd = { "pandoc", file, "-o", output }

  if format == "pdf" then
    -- Use a simple PDF engine
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

return M
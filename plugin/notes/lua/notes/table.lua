local M = {}

--- Prompt for table dimensions and insert a markdown table at cursor
function M.create(config)
  vim.ui.input({ prompt = "Rows (including header): " }, function(rows_input)
    if not rows_input then return end
    local rows = tonumber(rows_input)
    if not rows or rows < 1 then return end

    vim.ui.input({ prompt = "Columns: " }, function(cols_input)
      if not cols_input then return end
      local cols = tonumber(cols_input)
      if not cols or cols < 1 then return end

      -- Generate column headers with consistent width
      local headers = {}
      local col_widths = {}
      for c = 1, cols do
        local label = " Column " .. c .. " "
        headers[c] = label
        col_widths[c] = #label
      end

      -- Build markdown table
      local lines = {}

      -- Header row
      local header_line = "|"
      for c = 1, cols do
        header_line = header_line .. headers[c] .. "|"
      end
      table.insert(lines, header_line)

      -- Separator row (dashes matching column width)
      local sep_line = "|"
      for c = 1, cols do
        sep_line = sep_line .. string.rep("-", col_widths[c]) .. "|"
      end
      table.insert(lines, sep_line)

      -- Data rows (rows - 1, since header is already counted)
      for _ = 2, rows do
        local row = "|"
        for c = 1, cols do
          row = row .. string.rep(" ", col_widths[c]) .. "|"
        end
        table.insert(lines, row)
      end

      -- Insert at cursor
      local bufnr = vim.api.nvim_get_current_buf()
      local row = vim.api.nvim_win_get_cursor(0)[1] - 1
      vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
      vim.notify("Table " .. rows .. "x" .. cols .. " inserted", vim.log.levels.INFO)
    end)
  end)
end

return M
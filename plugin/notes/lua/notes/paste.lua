local M = {}

--- Detect the best available clipboard image target, or nil if none.
-- Tries Wayland (wl-paste) first, then X11 (xclip). Returns the MIME target
-- string (e.g. "image/png") that can be passed to the read command, plus the
-- backend name; or nil if no image is on the clipboard.
local function detect_clipboard_image()
  local backends = {
    wl = {
      check = "wl-paste --list-targets 2>/dev/null",
      read = function(target, dest) -- wl-paste -t image/png > file
        return string.format("wl-paste -t %s > %s", vim.fn.shellescape(target), vim.fn.shellescape(dest))
      end,
    },
    xclip = {
      check = "xclip -selection clipboard -t TARGETS -o 2>/dev/null",
      read = function(target, dest)
        return string.format("xclip -selection clipboard -o -t %s > %s", vim.fn.shellescape(target), vim.fn.shellescape(dest))
      end,
    },
  }

  for name, b in pairs(backends) do
    if vim.fn.executable(name == "wl" and "wl-paste" or "xclip") == 1 then
      local out = vim.fn.system(b.check)
      if vim.v.shell_error == 0 then
        -- Prefer image/png, otherwise first image/* target
        local png
        for target in out:gmatch("[^\r\n]+") do
          target = vim.trim(target)
          if target == "image/png" then png = target break end
        end
        if png then return png, name end
        for target in out:gmatch("[^\r\n]+") do
          target = vim.trim(target)
          if target:match("^image/") then return target, name end
        end
      end
    end
  end
  return nil
end

--- Build a smart default image path relative to the current page's directory.
-- Layout: <page-dir>/<page-basename>/image-<YYYYMMDD-HHMMSS>.png
-- i.e. a per-page subfolder named after the page, sitting next to the .md file.
local function default_image_path(page_path)
  local page_dir = vim.fn.fnamemodify(page_path, ":h")
  local page_basename = vim.fn.fnamemodify(page_path, ":t:r")
  local stamp = os.date("%Y%m%d-%H%M%S")
  return page_dir .. "/" .. page_basename .. "/image-" .. stamp .. ".png"
end

--- Paste the image currently on the clipboard into the notes vault.
-- Saves the file, then inserts a markdown image reference at the cursor.
function M.paste(config)
  local utils = require("notes.utils")
  if not utils.is_notes_buffer(config) then
    vim.notify("Not in a notes buffer", vim.log.levels.ERROR)
    return
  end

  local target, backend = detect_clipboard_image()
  if not target then
    vim.notify("No image found on clipboard (copied an image first?)", vim.log.levels.WARN)
    return
  end

  local page_path = vim.fn.expand("%:p")
  local suggested = default_image_path(page_path)

  -- Prompt the user, defaulting to the smart name (relative to the page dir is
  -- shown as a vault-relative-ish path for readability, but we resolve it next).
  vim.ui.input({ prompt = "Save image as (relative to notes dir): ", default = suggested }, function(answer)
    if not answer then return end -- user cancelled
    answer = vim.trim(answer)
    if answer == "" then answer = suggested end

    -- Resolve the chosen path against the notes dir so users can give a short
    -- name; if it's already absolute, use it as-is.
    local dest
    if answer:match("^/") then
      dest = answer
    else
      dest = config.notes_dir .. "/" .. answer
    end

    -- Force a sensible extension if missing
    if not dest:match("%.%w+$") then
      dest = dest .. ".png"
    end

    -- Create the per-page subfolder on first import
    local dir = vim.fn.fnamemodify(dest, ":h")
    vim.fn.mkdir(dir, "p")

    -- Dump the clipboard image to disk
    local read_cmd
    if backend == "wl" then
      read_cmd = string.format("wl-paste -t %s > %s", vim.fn.shellescape(target), vim.fn.shellescape(dest))
    else
      read_cmd = string.format("xclip -selection clipboard -o -t %s > %s", vim.fn.shellescape(target), vim.fn.shellescape(dest))
    end
    vim.fn.system(read_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to read image from clipboard", vim.log.levels.ERROR)
      return
    end

    -- Verify something was actually written (xclip silently succeeds on no data)
    if vim.fn.getfsize(dest) <= 0 then
      vim.notify("Clipboard image was empty", vim.log.levels.ERROR)
      vim.fn.delete(dest)
      return
    end

    -- Compute the markdown path relative to the page's directory
    local page_dir = vim.fn.fnamemodify(page_path, ":h")
    local rel = vim.fn.fnamemodify(dest, ":.") -- relative to cwd
    -- Prefer a path relative to the .md file's directory
    local md_rel
    if vim.startswith(dest, page_dir .. "/") then
      md_rel = dest:sub(#page_dir + 2)
    else
      -- Fallback: vault-relative from notes dir
      local nd = config.notes_dir
      if vim.startswith(dest, nd .. "/") then
        md_rel = dest:sub(#nd + 2)
      else
        md_rel = rel
      end
    end

    -- Insert markdown at cursor (works in normal mode; keeps cursor on the line)
    local bufnr = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    local inserted = "![](" .. md_rel .. ")"
    local new_line = before .. inserted .. after
    vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
    -- Place cursor just after the inserted text
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #inserted })

    vim.notify("Image saved: " .. dest, vim.log.levels.INFO)
  end)
end

return M
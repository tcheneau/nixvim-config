local M = {}


--- Clipboard backends for NotesPasteImage. `check` must exit 0 and print the
--- offered MIME targets (one per line) to stdout; `dump` then writes the
--- bytes of a given MIME target to a file.
--
-- NOTE: the wl-paste flag is --list-types; there is no --list-targets option
-- in any wl-clipboard release (2.2.1/2.3.0 both agree), so a wrong flag made
-- the check exit 1 and the Wayland backend was silently skipped every time.
-- Behaviour (per wl-paste.c): one MIME type per line on success, non-zero
-- exit with "Nothing is copied" when the clipboard is empty.
local backends = {
  wayland = {
    binary = "wl-paste",
    check = "wl-paste --list-types 2>&1",
    dump = function(target, dest) -- wl-paste -t image/png > file
      return string.format("wl-paste -t %s > %s", vim.fn.shellescape(target), vim.fn.shellescape(dest))
    end,
  },
  x11 = {
    binary = "xclip",
    check = "xclip -selection clipboard -t TARGETS -o 2>&1",
    dump = function(target, dest)
      return string.format("xclip -selection clipboard -o -t %s > %s", vim.fn.shellescape(target), vim.fn.shellescape(dest))
    end,
  },
}

--- Preferred file extension for clipboard image MIME targets we can handle.
local image_extensions = {
  ["image/png"] = "png",
  ["image/jpeg"] = "jpg",
  ["image/jpg"] = "jpg",
  ["image/gif"] = "gif",
  ["image/bmp"] = "bmp",
  ["image/webp"] = "webp",
  ["image/tiff"] = "tif",
}

--- File extension to use for a clipboard image MIME target (png fallback).
function M.image_extension(target)
  return image_extensions[target] or "png"
end

--- Ordered clipboard backend candidate list for the execution context.
-- config.clipboard_image_backend ("auto" | "wayland" | "x11"; default
-- "auto") forces a stack, otherwise the environment decides: Wayland first
-- when WAYLAND_DISPLAY is set or XDG_SESSION_TYPE is "wayland", X11 first
-- when only DISPLAY is set or XDG_SESSION_TYPE is "x11". The other stack
-- always stays as a harmless fallback.
local function backend_order(config)
  local forced = config and config.clipboard_image_backend or nil
  if forced == "wayland" or forced == "x11" then
    return { forced, forced == "wayland" and "x11" or "wayland" }
  end

  local session = vim.env.XDG_SESSION_TYPE or ""
  local on_wayland = (vim.env.WAYLAND_DISPLAY ~= nil and vim.env.WAYLAND_DISPLAY ~= "") or session == "wayland"
  local on_x11 = (vim.env.DISPLAY ~= nil and vim.env.DISPLAY ~= "") or session == "x11"
  if on_x11 and not on_wayland then
    return { "x11", "wayland" }
  end
  return { "wayland", "x11" }
end

--- Detect the best available clipboard image target, or nil if none.
-- Probes the backends in context order (see backend_order): run its check,
-- then pick image/png if offered, else the first image/* target. Returns
-- the MIME target string (e.g. "image/png") that can be passed to `dump`,
-- the backend name, and a human-readable reason string when no image could
-- be found (missing binary, backend failure, or text-only clipboard).
-- Exposed for testing.
function M.detect_clipboard_image(config)
  local reasons = {}
  for _, name in ipairs(backend_order(config)) do
    local b = backends[name]
    if vim.fn.executable(b.binary) ~= 1 then
      reasons[#reasons + 1] = name .. ": " .. b.binary .. " not found in $PATH"
    else
      local out = vim.fn.system(b.check)
      if vim.v.shell_error ~= 0 then
        local detail = vim.trim(out):match("^([^\r\n]+)") or ("exit code " .. vim.v.shell_error)
        if #detail > 120 then detail = detail:sub(1, 117) .. "..." end
        reasons[#reasons + 1] = name .. ": " .. b.binary .. " failed: " .. detail
      else
        -- Prefer image/png, otherwise the first image/* target
        local png, any
        for line in out:gmatch("[^\r\n]+") do
          local target = vim.trim(line)
          if target == "image/png" and not png then png = target end
          if not any and target:match("^image/") then any = target end
        end
        if png or any then
          return png or any, name
        end
        reasons[#reasons + 1] = name .. ": clipboard has no image target"
      end
    end
  end
  return nil, nil, table.concat(reasons, "; ")
end

--- Build a smart default image path relative to the current page's directory.
-- Layout: <page-dir>/<page-basename>/image-<YYYYMMDD-HHMMSS>.<ext>
-- i.e. a per-page subfolder named after the page, sitting next to the .md
-- file. The extension matches the clipboard MIME target (png by default).
function M.default_image_path(page_path, target)
  local page_dir = vim.fn.fnamemodify(page_path, ":h")
  local page_basename = vim.fn.fnamemodify(page_path, ":t:r")
  local stamp = os.date("%Y%m%d-%H%M%S")
  return page_dir .. "/" .. page_basename .. "/image-" .. stamp .. "." .. M.image_extension(target)
end

--- Paste the image currently on the clipboard into the notes vault.
-- Saves the file, then inserts a markdown image reference at the cursor.
function M.paste(config)
  local utils = require("notes.utils")
  if not utils.is_notes_buffer(config) then
    vim.notify("Not in a notes buffer", vim.log.levels.ERROR)
    return
  end

  local target, backend, reason = M.detect_clipboard_image(config)
  if not target then
    vim.notify("No image found on clipboard: " .. reason, vim.log.levels.WARN)
    return
  end

  local page_path = vim.fn.expand("%:p")
  local suggested = M.default_image_path(page_path, target)

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
      dest = dest .. "." .. M.image_extension(target)
    end

    -- Create the per-page subfolder on first import
    local dir = vim.fn.fnamemodify(dest, ":h")
    vim.fn.mkdir(dir, "p")

    -- Dump the clipboard image to disk with the backend that was detected
    vim.fn.system(backends[backend].dump(target, dest))
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
local M = {}

M.config = {}

local defaults = {
  notes_dir = "~/notes",
  journal_dir = "~/notes/journal",
  templates_dir = "~/notes/templates",
  pages_dir = "~/notes/pages",
  journal_template = "daily",
  default_template = nil,
  -- Clipboard backend for NotesPasteImage: "auto" detects the session
  -- (Wayland first when WAYLAND_DISPLAY is set, X11 otherwise) and always
  -- falls back to the other stack; or force "wayland" / "x11".
  clipboard_image_backend = "auto",
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", defaults, opts or {})

  -- Expand ~ and env vars in paths
  for _, key in ipairs({ "notes_dir", "journal_dir", "templates_dir", "pages_dir" }) do
    M.config[key] = vim.fn.expand(M.config[key])
  end

  -- Create directories if they don't exist
  for _, key in ipairs({ "notes_dir", "journal_dir", "templates_dir", "pages_dir" }) do
    vim.fn.mkdir(M.config[key], "p")
  end

  -- Register user commands
  -- NotesJournal: today (no arg), a parsed date (arg), or prompt (empty arg via !)
  vim.api.nvim_create_user_command("NotesJournal", function(args)
    require("notes.journal").open(M.config, args.args)
  end, {
    nargs = "?",
    desc = "Open a journal entry. With no argument opens today; with an argument opens that date (YYYY-MM-DD, YYYYMMDD, today, yesterday, +2d, -1w, +1m, ...).",
  })

  -- NotesJournalDate: always prompt for a date (handy keymap target)
  vim.api.nvim_create_user_command("NotesJournalDate", function()
    require("notes.journal").open(M.config, nil)
  end, {
    desc = "Prompt for a date and open that journal entry.",
  })

  vim.api.nvim_create_user_command("NotesFind", function()
    require("notes.search").find_pages(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesSearch", function()
    require("notes.search").live_grep(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesTags", function()
    require("notes.search").find_tags(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesBacklinks", function()
    require("notes.backlinks").show(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesToggleTask", function()
    require("notes.tasks").toggle()
  end, {})

  vim.api.nvim_create_user_command("NotesNew", function()
    require("notes.links").new_page(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesFollowLink", function()
    require("notes.links").follow(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesTemplate", function(args)
    require("notes.templates").insert(M.config, args.args)
  end, {
    nargs = "?",
    complete = function()
      return require("notes.templates").list(M.config)
    end,
  })

  vim.api.nvim_create_user_command("NotesExport", function(args)
    require("notes.export").export(M.config, args.args)
  end, {
    nargs = "?",
    complete = function()
      return { "html", "pdf" }
    end,
  })

  vim.api.nvim_create_user_command("NotesExportOpen", function(args)
    require("notes.export").export_and_open(M.config, args.args)
  end, {
    nargs = "?",
    complete = function()
      return { "html", "pdf" }
    end,
  })

  vim.api.nvim_create_user_command("NotesGit", function()
    require("notes.git").open(M.config)
  end, {})

  vim.api.nvim_create_user_command("NotesTable", function()
    require("notes.table").create(M.config)
  end, {})

  -- NotesPasteImage: save the clipboard image into a per-page subfolder and
  -- insert a markdown image reference at the cursor.
  vim.api.nvim_create_user_command("NotesPasteImage", function()
    require("notes.paste").paste(M.config)
  end, {
    desc = "Paste image from clipboard: save to <page>/image-<timestamp>.png and insert markdown.",
  })
end

return M
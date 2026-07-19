local M = {}

M.config = {}

local defaults = {
  notes_dir = "~/notes",
  journal_dir = "~/notes/journal",
  templates_dir = "~/notes/templates",
  pages_dir = "~/notes/pages",
  journal_template = "daily",
  default_template = nil,
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
  vim.api.nvim_create_user_command("NotesJournal", function()
    require("notes.journal").open_today(M.config)
  end, {})

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
end

return M
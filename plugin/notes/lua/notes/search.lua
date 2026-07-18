local M = {}

function M.find_pages(config)
  require("telescope.builtin").find_files({
    cwd = config.notes_dir,
    prompt_title = "Notes: Find Page",
    find_command = { "rg", "--files", "--type", "md" },
  })
end

function M.live_grep(config)
  require("telescope.builtin").live_grep({
    cwd = config.notes_dir,
    prompt_title = "Notes: Search",
  })
end

function M.find_tags(config)
  require("telescope.builtin").live_grep({
    cwd = config.notes_dir,
    prompt_title = "Notes: Tags",
    default_text = "#",
  })
end

return M
local M = {}

--- Open LazyGit in the notes directory
function M.open(config)
  vim.cmd("tcd " .. vim.fn.fnameescape(config.notes_dir))
  vim.cmd("LazyGit")
end

return M
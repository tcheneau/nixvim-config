{
  plugins.render-markdown = {
    enable = true;
    settings = {
      # Disabled by default, enabled per-buffer via autocommand below
      enabled = false;
      signs.enabled = false;
    };
  };

  # Enable render-markdown only for markdown files in the notes directory
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(args)
        local notes_dir = vim.fn.expand("~/Notes/notes-org/")
        local buf_path = vim.api.nvim_buf_get_name(args.buf)
        if buf_path:match("^" .. vim.pesc(notes_dir)) then
          vim.schedule(function()
            vim.cmd("RenderMarkdown enable")
          end)
        end
      end,
    })
  '';
}

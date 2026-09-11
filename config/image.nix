{ pkgs, ... }:

{
  # image.nvim requires curl for downloading remote images
  extraPackages = [ pkgs.curl ];

  extraPlugins = [ pkgs.vimPlugins.image-nvim ];

  # Only initialize in a real terminal (skips headless mode / nix flake check)
  extraConfigLua = ''
    if #vim.api.nvim_list_uis() > 0 then
      require("image").setup({
        backend = "kitty",
        max_width = 100,
        max_height = 12,
        window_overlap_clear_enabled = true,
        integrations = {
          markdown = {
               enabled = true,
               download_remote_images = true
             },
        },
      })

      -- Toggle image rendering in markdown buffers
      -- Sets images_toggled so the FileType default (disabled) doesn't clobber
      -- the user's choice when the buffer is reloaded
      vim.api.nvim_create_user_command("ToggleImages", function()
        local buf = vim.api.nvim_get_current_buf()
        vim.b[buf].images_toggled = true
        if vim.b[buf].images_disabled then
          -- Currently disabled, enable by reloading buffer
          vim.b[buf].images_disabled = false
          vim.cmd("edit")
          vim.notify("Images enabled", vim.log.levels.INFO)
        else
          -- Currently enabled, disable by clearing images
          vim.b[buf].images_disabled = true
          require("image").clear()
          vim.notify("Images disabled", vim.log.levels.INFO)
        end
      end, {})

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
          -- Default: disable image rendering on markdown buffers (unless the
          -- user explicitly toggled this buffer)
          if not vim.b[args.buf].images_toggled then
            vim.b[args.buf].images_disabled = true
          end
        end,
      })
      vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "TextChangedI", "WinResized" }, {
        callback = function(args)
          if vim.b[args.buf].images_disabled then
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(args.buf) then
                require("image").clear()
              end
            end)
          end
        end,
      })
    end
  '';
}

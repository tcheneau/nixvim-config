{ plugins.bufferline = { 
    enable = true;
    settings.options = {
      always_show_bufferline = true;
      buffer_close_icon = "󰅙";
      close_icon = "";
      left_trunc_marker = " ";
      right_trunc_marker = " ";
      get_element_icon = ''
        function(element)
          -- element consists of {filetype: string, path: string, extension: string, directory: string}
          -- This can be used to change how bufferline fetches the icon
          -- for an element e.g. a buffer or a tab.
          -- e.g.
          local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(opts.filetype, { default = false })
          return icon, hl
        end
      '';
      diagnostics = "nvim_lsp";
      diagnostics_indicator = ''
        function(count, level, diagnostics_dict, context)
          local s = ""
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " "
              or (e == "warning" and " " or "" )
            if(sym ~= "") then
              s = s .. " " .. n .. sym
            end
          end
          return s
        end
      '';
      right_mouse_command = "bdelete! %d"; # -- can be a string | function | false, see "Mouse actions"
      hover.enabled = true;
      indicator = {
        icon = "▎";
        style = "icon";
      };
      separator_style = [
        ""
        ""
      ];
      };
  };
}

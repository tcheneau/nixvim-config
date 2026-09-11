{
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>fg" = "live_grep";
      "<C-à>" = {
        action = "find_files";
        options = {
          desc = "Telescope find Files";
        };
      };
      "<C-p>" = {
        action = "git_files";
        options = {
          desc = "Telescope Git Files";
        };
      };
      "<C-k>" = {
        action = "buffers";
        options = {
          desc = "Telescope Buffers";
        };
      };
    };
    extensions.fzf-native = {
      enable = true;
    };
  };
}

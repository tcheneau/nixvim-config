{
  plugins = {
    alpha = {
      enable = true;
      settings.layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          type = "text";
          val = [
            "                                                              ░░                        "
            "                                                            ░░▒█░                       "
            "                                                          ░░▒░▒░                        "
            "                                                       ░░▒░▒▒░                          "
            "                                                     ░░░░▒▒                             "
            "                                                   ░▒░▒▒░                               "
            "                                                 ░▒░▒▒░                                 "
            "                                                ░░▒▒░                                   "
            "                                ░▒▒▒▒▒▒▒▒▒░   ▒░▒▒░                                    "
            "                            ░░▒▒▒▒▒▓▓▓▓▓▒▒░░▒▒▒▒▒░                                      "
            "                          ░░▒░▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒░                                       "
            "                         ░▒░░▓▓██▓▓▒▓▒▒▓▓▓█▓░▒▒▒▒▒                                      "
            "                        ░▒▒▒▒▓█▓▓▒▒▒▒▒▓█▓▓▓▒▓█▓▒░▒▒                                     "
            "                       ░▒▒░░░▒█▓▒▓▓▓▓▒▓▒▒▓▒███▒▒▒▒▒▒                                    "
            "                      ░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓█▓██▓▒▒▒▒▒▒▒▒▒░                                  "
            "                     ░▒▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▒▒▒░                                 "
            "                     ▒▒▒▓▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒                                 "
            "                    ▒▓▓▓▓▒▒▒▒░░░▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒▒▒▒▒▒░                                "
            "                    ▒▓▓▓▓▒▒▓▓▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒▒▓▒▒▒▒▒▓▒▒▒                                "
            "                   ░▒▒▒▓▓▓▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▒▓▓▓▓▒                                "
            "                   ░▒▒▓▓▓▓▒▓▓▓▓▓▓▓▓▓▓▓▓▒▓▓▓▓▓▓▓▓▒▒▓▒▒▒▓▓▒                                "
            "                   ░▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▓▒                                "
            "                    ▒▓▓▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▓▓▒                                "
            "                    ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░                                "
            "                     ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒                                 "
            "                     ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░                                 "
            "                     ░░▒▒▒▒▓▓▓▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░░                                  "
            "                     ░░░▒▒▒▒▒▒▓▒▓▒▓▒▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░                                  "
            "                      ░░░░▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░                                   "
            "                        ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▒▒▒░░░░░                                     "
            "                          ░░░░░░▒▒▒▒▒▒▒▒▒░░░░░░░░                                       "
            "                            ░░░░░░░░░░░░░░░░░                                           "
          ];
          opts = {
            position = "center";
            hl = "Type";
          };
        }
        {
          type = "padding";
          val = 4;
        }
        {
          type = "group";
          val = [
            {
              type = "button";
              val = "      New File    ";
              on_press.__raw = "function() vim.cmd[[ene]] end";
              opts = {
                shortcut = "n";
                keymap = [
                  "n"
                  "n"
                  "<cmd>ene<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 1;
            }
            {
              type = "button";
              val = "   󰀰   New Note    ";
              on_press.__raw = "function() vim.cmd[[NotesNew]] end";
              opts = {
                shortcut = "o";
                keymap = [
                  "n"
                  "o"
                  "<cmd>NotesNew<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 1;
            }
            {
              type = "button";
              val = "   󰁞   Journal    ";
              on_press.__raw = "function() vim.cmd[[NotesJournal]] end";
              opts = {
                shortcut = "j";
                keymap = [
                  "n"
                  "j"
                  "<cmd>NotesJournal<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 1;
            }
            {
              type = "button";
              val = "      Find File    ";
              on_press.__raw = "function() vim.cmd[[Telescope find_files]] end";
              opts = {
                shortcut = "f";
                keymap = [
                  "n"
                  "f"
                  "<cmd>Telescope find_files<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 1;
            }
            {
              type = "button";
              val = "      Recent Files    ";
              on_press.__raw = "function() vim.cmd[[Telescope oldfiles]] end";
              opts = {
                shortcut = "r";
                keymap = [
                  "n"
                  "r"
                  "<cmd>Telescope oldfiles<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 1;
            }
            {
              type = "button";
              val = "      Live Grep    ";
              on_press.__raw = "function() vim.cmd[[Telescope live_grep]] end";
              opts = {
                shortcut = "g";
                keymap = [
                  "n"
                  "g"
                  "<cmd>Telescope live_grep<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 1;
            }
            {
              type = "button";
              val = "      LazyGit    ";
              on_press.__raw = "function() vim.cmd[[LazyGit]] end";
              opts = {
                shortcut = "l";
                keymap = [
                  "n"
                  "l"
                  "<cmd>LazyGit<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "padding";
              val = 2;
            }
            {
              type = "button";
              val = "      Quit Neovim    ";
              on_press.__raw = "function() vim.cmd[[qa]] end";
              opts = {
                shortcut = "q";
                keymap = [
                  "n"
                  "q"
                  "<cmd>qa<CR>"
                  {
                    noremap = true;
                    silent = true;
                    nowait = true;
                  }
                ];
                position = "center";
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
          ];
        }
      ];
    };
  };
}

{ lib, ... }:

let
  # Spacing used between dashboard buttons
  pad1 = {
    type = "padding";
    val = 1;
  };
  pad2 = {
    type = "padding";
    val = 2;
  };

  # Build an alpha dashboard button from an (icon +) label, shortcut key, and command
  mkButton = val: shortcut: cmd: {
    type = "button";
    inherit val;
    on_press.__raw = "function() vim.cmd[[${cmd}]] end";
    opts = {
      inherit shortcut;
      keymap = [
        "n"
        shortcut
        "<cmd>${cmd}<CR>"
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
  };

  buttons = [
    (mkButton "      New File    " "n" "ene")
    (mkButton "   󰀰   New Note    " "o" "NotesNew")
    (mkButton "   󰁞   Journal    " "j" "NotesJournal")
    (mkButton "   󰈙   Find Note    " "p" "NotesFind")
    (mkButton "   󰬎   Search Notes  " "s" "NotesSearch")
    (mkButton "      Find File    " "f" "Telescope find_files")
    (mkButton "      Recent Files    " "r" "Telescope oldfiles")
    (mkButton "      Live Grep    " "g" "Telescope live_grep")
    (mkButton "      LazyGit    " "l" "LazyGit")
    (mkButton "      Quit Neovim    " "q" "qa")
  ];

  # Preserve the original spacing: one pad between buttons,
  # with extra breathing room before the Quit button
  # (lib.flatten is needed because lib.init above returns a list of
  # [ button padding ] pairs, and alpha expects a flat element list)
  buttonGroup =
    lib.flatten (
      lib.init (
        map (b: [
          b
          pad1
        ]) buttons
      )
    )
    ++ [
      pad2
      (lib.last buttons)
    ];
in
{
  plugins.alpha = {
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
        val = buttonGroup;
      }
    ];
  };
}

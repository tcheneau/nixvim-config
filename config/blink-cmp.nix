{
  plugins = {
    # Keep luasnip as the snippet backend for blink-cmp
    luasnip.enable = true;

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap.preset = "super-tab";
        sources = {
          default = [ "lsp" "path" "snippets" "buffer" "emoji" "notes_wiki" "notes_slash" ];
          providers.emoji = {
            module = "blink-emoji";
            name = "Emoji";
            score_offset = 15;
            opts.insert = true;
          };
          providers.notes_wiki = {
            module = "notes.completion.wiki";
            name = "Notes Wiki";
            score_offset = 100;
          };
          providers.notes_slash = {
            module = "notes.completion.slash";
            name = "Notes Slash";
            score_offset = 100;
          };
        };
        completion = {
          documentation.auto_show = true;
          ghost_text.enabled = true;
        };
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "normal";
        };
        signature.enabled = true;
      };
    };

    blink-emoji.enable = true;
  };
}

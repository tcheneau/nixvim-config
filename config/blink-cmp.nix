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
          default = [ "lsp" "path" "snippets" "buffer" "emoji" ];
          providers.emoji = {
            module = "blink-emoji";
            name = "Emoji";
            score_offset = 15;
            opts.insert = true;
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

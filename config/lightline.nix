{
  plugins.lightline = {
    enable = false;
    settings = {
      colorscheme = "material";
    };
  };

  plugins.lualine = {
    enable = true;
    settings.options = {
      theme = "dracula";
      section_separators = { left = ""; right = ""; };
      component_separators = { left = ""; right = ""; };
    };
  };
}

# NOTE: pinned nixvim has no `plugins.outline` module, so the plugin is
# wired up manually. Once nixvim is updated to a version that ships
# `plugins.outline`, replace this with `plugins.outline.enable = true;`.
{ pkgs, ... }:

{
  extraPlugins = [ pkgs.vimPlugins.outline-nvim ];

  extraConfigLua = ''
    require("outline").setup {}
  '';
}

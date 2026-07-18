{
  imports = [
            ./alpha.nix
            ./blink-cmp.nix
            ./bufferline.nix
            ./codecompanion.nix
            ./conform-nvim.nix
            ./git.nix
            ./keymaps.nix
            ./lint.nix
            ./lualine.nix
            ./lsp/default.nix
            ./lsp/fidget.nix
            ./lsp/trouble.nix
            ./noice.nix
            ./nvim-tree.nix
            ./oil.nix
            ./options.nix
            ./outline.nix
            ./treesitter.nix
            ./utils/auto-pairs.nix
            ./utils/autosave.nix
            ./utils/blankline.nix
            ./utils/lazygit.nix
            ./utils/telescope.nix
            ./utils/toggleterm.nix
            ./utils/which-key.nix
  ];

  plugins.web-devicons.enable = true;
  plugins.notify.enable = true;
  colorschemes.tokyonight.enable = true;
}
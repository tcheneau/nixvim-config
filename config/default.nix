{
  imports = [
            ./alpha.nix
            ./bufferline.nix
            ./cmp.nix
            ./conform-nvim.nix
            ./git.nix
            ./keymaps.nix
            ./lightline.nix
            ./lsp/default.nix
            ./lsp/fidget.nix
            ./lsp/ionide.nix
            ./lsp/none-ls.nix
            ./lsp/trouble.nix
            ./noice.nix
            ./nvim-tree.nix
            ./outline.nix
            ./options.nix
            ./treesitter.nix
            ./utils/auto-pairs.nix
            ./utils/autosave.nix
            ./utils/blankline.nix
            ./utils/lazygit.nix
            ./utils/telescope.nix
            ./utils/toggleterm.nix
            ./utils/which-key.nix
            ./utils/wilder.nix
  ];

  plugins.web-devicons.enable = true;
  plugins.notify.enable = true;
  colorschemes.tokyonight.enable = true;
}

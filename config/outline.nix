{pkgs, ...}: let
  outline-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "outline-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "hedyhli";
      repo = "outline.nvim";
      rev = "d5c29ee3ff3b7d1bdd454b37698316e67808c36e";
      hash = "sha256-uWMHUkrGo8D3nUvYrDcXOWbXLWvFv9rWsBxLfR2ckcY=";
    };
    nvimSkipModule = "outline.providers.norg";
  };
in {
  extraPlugins = with pkgs; [
    outline-nvim # Document outliner
  ];

  extraConfigLua = ''
    require("outline").setup {}
  '';
}

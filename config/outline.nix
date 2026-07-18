{pkgs, ...}: let
  outline-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "outline-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "hedyhli";
      repo = "outline.nvim";
      rev = "c293eb56db880a0539bf9d85b4a27816960b863e";
      hash = "sha256-uWMHUkrGo8D3nUvYrDcXOWbXLWvFv9rWsBxLfR2ckcY=";
    };
    version = "0.0.1";
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

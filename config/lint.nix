{
  plugins.lint = {
    enable = true;
    autoInstall.enable = true;
    lintersByFt = {
      nix = [ "statix" ];
    };
  };
}

{
  plugins.lint = {
    enable = true;
    autoInstall.enable = true;
    lintersByFt = {
      nix = [ "statix" ];
    };
  };

  # nvim-lint only configures linters; something must call `try_lint`
  autoCmd = [
    {
      event = [
        "BufWritePost"
        "InsertLeave"
      ];
      callback.__raw = ''
        function()
          require("lint").try_lint()
        end
      '';
    }
  ];
}

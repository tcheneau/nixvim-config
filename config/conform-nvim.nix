{ pkgs, ... }:

{
  plugins.conform-nvim = {
    enable = true;
    autoInstall = {
      enable = true;
      overrides = {
        golines = pkgs.golines;
        nixfmt = pkgs.nixfmt;
        shellharden = pkgs.shellharden;
        shfmt = pkgs.shfmt;
      };
    };
    settings = {
      formatters_by_ft = {
        go = [ "goimports" "golines" ];
        nix = [ "nixfmt" ];
        markdown = [ "markdownlint" ];
        sh = [ "shellharden" "shfmt" ];
      };
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 1000;
      };
    };
  };
}
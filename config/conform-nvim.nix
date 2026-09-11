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
        go = [
          "goimports"
          "golines"
        ];
        nix = [ "nixfmt" ];
        markdown = [ "markdownlint" ];
        # shfmt normalizes first, shellharden hardens on top;
        # the other way around shfmt would undo the hardening
        sh = [
          "shfmt"
          "shellharden"
        ];
      };
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 1000;
      };
    };
  };
}

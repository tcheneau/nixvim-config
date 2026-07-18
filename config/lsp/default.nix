{ pkgs, ... }:

{
  # golangci-lint-langserver wraps the golangci-lint CLI,
  # which must be available in PATH at runtime
  extraPackages = [ pkgs.golangci-lint ];

  plugins = {
    lsp = {
      enable = true;
      servers = {
        # Common language servers
        bashls.enable = true;
        clangd.enable = true;
        nixd.enable = true;
        ruff.enable = true;
        gopls = {
          enable = true;
          settings = {
            gopls = {
              completeUnimported = true;
              gofumpt = true;
              codelenses = {
                 tidy = true;
              };
            };
          };
        };
        golangci_lint_ls.enable = true;
      };
      keymaps.lspBuf = {
        "gd" = "definition";
        "gr" = "references";
        "gt" = "type_definition";
        "gi" = "implementation";
        "K" = "hover";
      };
    };
    rustaceanvim.enable = true;
  };
}

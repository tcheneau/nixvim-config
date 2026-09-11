{ pkgs, ... }:

{
  # rustaceanvim needs rust-analyzer on PATH at runtime
  extraPackages = [ pkgs.rust-analyzer ];

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
        # golangci-lint-langserver wraps the golangci-lint CLI, so it is
        # launched through a wrapper that only puts golangci-lint on the
        # PATH of this language server (not for every LSP session)
        golangci_lint_ls = {
          enable = true;
          cmd = [
            "${pkgs.writers.writeBash "golangci-lint-ls-wrapper" ''
              export PATH="${pkgs.golangci-lint}/bin:$PATH"
              exec "${pkgs.golangci-lint-langserver}/bin/golangci-lint-langserver" "$@"
            ''}"
          ];
        };
      };
      keymaps.lspBuf = {
        "gd" = "definition";
        "gr" = "references";
        "gt" = "type_definition";
        "gi" = "implementation";
        "K" = "hover";
      };
      keymaps.diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
        "<leader>de" = "open_float";
      };
    };
    rustaceanvim.enable = true;
  };
}

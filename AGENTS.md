# AGENTS.md - NixVim Configuration

## Project Overview

NixVim configuration using [nixvim](https://github.com/nix-community/nixvim) - a declarative Neovim configuration built with Nix flakes using **flake-parts**.

## Essential Commands

### Build & Test
```bash
# Build all configurations
nix build

# Run a specific configuration
nix run .#<name>

# Run default configuration
nix run

# Test configuration (validates it builds)
nix flake check

# Format Nix files
nix fmt
```

### Development Shell
```bash
# Enter dev shell with language tooling
nix develop
```

## Architecture

### Flake Structure
This configuration uses **flake-parts** for modular flake development:

```
flake.nix
├── inputs: nixpkgs, nixvim, flake-parts
├── nixvim.packages.enable = true  # Auto-install packages
├── nixvim.checks.enable = true    # Auto-add checks
└── perSystem.nixvimConfigurations.default
    └── evalNixvim with ./config module
```

### Configuration Structure
```
config/
├── default.nix          # Entry point - imports all modules, global keymaps
├── options.nix          # Neovim options/settings
├── lsp/                 # LSP configuration
│   ├── default.nix      # Core LSP servers (bashls, clangd, nixd, gopls, etc.)
│   ├── fidget.nix       # LSP progress notifications
│   ├── ionide.nix       # F# language support
│   ├── none-ls.nix      # Null-ls integrations
│   └── trouble.nix      # Diagnostics list
└── utils/               # Utility plugins
    ├── telescope.nix    # Fuzzy finder
    ├── which-key.nix    # Keybinding popup
    └── ...
```

### Key Configuration Files
- `flake.nix` - Uses flake-parts pattern with `evalNixvim`
- `config/default.nix` - Main configuration module, imports all plugins, defines global keymaps
- `config/options.nix` - Base Neovim options

## Keybindings (Leader = Space)

### File Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `<C-n>` | `NvimTreeToggle` | Toggle file explorer |
| `<C-à>` | `telescope find_files` | Fuzzy find files |
| `<C-p>` | `telescope git_files` | Fuzzy find git files |
| `<leader>fg` | `telescope live_grep` | Live grep search |

### Git (gitsigns)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>lg` | `LazyGit` | Open LazyGit UI |
| `<leader>gtb` | `Gitsigns toggle_current_line_blame` | Toggle line blame |
| `<leader>gtd` | `Gitsigns toggle_deleted` | Toggle deleted signs |
| `<leader>gd` | `Gitsigns diffthis` | Diff this buffer |
| `<leader>grh` | `Gitsigns reset_hunk` | Reset hunk |
| `<leader>grb` | `Gitsigns reset_buffer` | Reset entire buffer |

### Diagnostics & Debug
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>dt` | `Trouble diagnostics toggle` | Toggle diagnostics list |

### Formatting
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>fm` | `vim.lsp.buf.format()` | Format current buffer |

### Tabs/Buffers
| Key | Action | Description |
|-----|--------|-------------|
| `<C-s>` | `BufferLinePick` | Pick/select buffer |
| `<leader>tn` | `tabnew` | Create new tab |
| `<leader>td` | `tabclose` | Close current tab |
| `<leader>ts` | `tabnext` | Go to next tab |
| `<leader>tp` | `tabprevious` | Go to previous tab |

### Treesitter
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>co` | `TSContextToggle` | Toggle code context |

### Terminal
| Key | Action | Description |
|-----|--------|-------------|
| `<esc>` (terminal mode) | `<C-\><C-n>` | Escape to normal mode |

## Plugin Categories

### Core
- **bufferline** - Buffer tabs with hover preview
- **lightline** - Status line
- **nvim-tree** - File explorer tree
- **telescope** - Fuzzy finder (with fzf-native extension)
- **treesitter** - Syntax highlighting & indentation
- **which-key** - Keybinding popup hints
- **wilder** - Command line completion

### LSP & Completion
- **lsp** - Language Server Protocol (bashls, clangd, nixd, gopls, ruff, etc.)
- **cmp** - Completion framework (nvim_lsp, luasnip, buffer, path sources)
- **luasnip** - Snippet engine
- **fidget** - LSP progress notifications in corner
- **trouble** - Pretty diagnostics/references list
- **rustaceanvim** - Rust LSP integration

### Git
- **gitsigns** - Git decorations, hunks, blame
- **lazygit** - Terminal Git UI

### AI/LLM
- **chatgpt** - ChatGPT integration (LiteLLM backend)
- **parrot** - Multi-provider LLM plugin (Mistral, etc.)
- **copilot-chat** - GitHub Copilot chat (disabled by default)

### Utilities
- **noice** - Modern UI notifications
- **toggleterm** - Multiple terminal windows
- **autosave** - Auto-save to disk
- **auto-pairs** - Auto-close brackets/quotes
- **blankline** - Indent guides
- **outline** - Document outline/symbols
- **conform-nvim** - Code formatting

## Nix Patterns

### Module Structure
All config files are Nix modules returning attribute sets:
```nix
{
  plugins.<name>.enable = true;
  plugins.<name>.settings = { ... };
}
```

### Keymaps
Keymaps defined as list in `config/default.nix`:
```nix
keymaps = [
  {
    mode = "n";  # n=normal, v=visual, t=terminal, ""=normal-visual-op
    key = "<leader>x";
    action = "<CMD>Command<CR>";
    options.desc = "Description";
  }
];
```

### Lua Code in Nix
Lua functions embedded as raw strings:
```nix
settings.snippet.expand = ''
  function(args)
    require('luasnip').lsp_expand(args.body)
  end
'';
```

### Using vimPlugins
For custom plugins not in nixvim, use nixpkgs vimPlugins:
```nix
{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    outline-nvim
  ];
}
```

## Gotchas

1. **Plugin pname attribute**: When using `extraPlugins`, always use plugins from `pkgs.vimPlugins` which have the required `pname` attribute. Custom `buildVimPlugin` calls without `pname` will fail.

2. **Keymap mode**: `mode = ""` means normal-visual-op. Use explicit `"n"` for normal-only.

3. **LSP server names**: Use nixvim's server names (e.g., `gopls`, `nixd`, `bashls`), not binary names.

4. **Formatter**: Project uses `nixpkgs-fmt` via `nix fmt`. CI auto-commits formatting changes.

5. **Dev shell**: Contains language tooling (Rust, Go, F#, Kotlin, Elixir, Gleam). Run `nix develop` before working with LSP servers.

6. **Testing**: `nix flake check` validates configuration builds - run before committing.

7. **flake-parts**: This flake uses flake-parts pattern. Add new inputs at top level, configurations in `perSystem.nixvimConfigurations`.

## Adding New Plugins

1. Add plugin config file in `config/` or `config/utils/`
2. Import in `config/default.nix`
3. Enable: `plugins.<name>.enable = true`
4. Add keymaps to `config/default.nix` if needed
5. Run `nix build` to verify

## CI/CD

- **build.yml**: Runs `nix flake check` and `nix build` on PR/push
- **format.yml**: Auto-formats with `nix fmt` and commits changes
- **flake.yml**: Weekly automated flake.lock updates

## References

- [NixVim Documentation](https://nix-community.github.io/nixvim/)
- [flake-parts Documentation](https://flake.parts/)
- [NixOS Wiki - Neovim](https://wiki.nixos.org/wiki/Neovim)

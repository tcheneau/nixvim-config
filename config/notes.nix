{ pkgs, ... }:
let
  notes = pkgs.vimUtils.buildVimPlugin {
    pname = "notes";
    version = "0.0.1";
    src = ../plugin/notes;
  };
in
{
  # pandoc for :NotesExport, ripgrep is already available via telescope
  extraPackages = [ pkgs.pandoc ];

  extraPlugins = [ notes ];

  extraConfigLua = ''
    require("notes").setup({
      notes_dir = "~/Notes/notes-org",
      journal_dir = "~/Notes/notes-org/journals",
      templates_dir = "~/Notes/notes-org/templates",
      pages_dir = "~/Notes/notes-org/pages",
      journal_template = "daily",
      default_template = nil,
    })
  '';

  keymaps = [
    { mode = "n"; key = "<leader>n"; action = "+notes"; }
    { mode = "n"; key = "<leader>nj"; action = "<CMD>NotesJournal<CR>"; options.desc = "Journal (today)"; }
    { mode = "n"; key = "<leader>np"; action = "<CMD>NotesFind<CR>"; options.desc = "Find page"; }
    { mode = "n"; key = "<leader>nw"; action = "<CMD>NotesSearch<CR>"; options.desc = "Search words"; }
    { mode = "n"; key = "<leader>nb"; action = "<CMD>NotesBacklinks<CR>"; options.desc = "Backlinks"; }
    { mode = "n"; key = "<leader>nd"; action = "<CMD>NotesToggleTask<CR>"; options.desc = "Toggle task"; }
    { mode = "n"; key = "<leader>nn"; action = "<CMD>NotesNew<CR>"; options.desc = "New page"; }
    { mode = "n"; key = "<leader>nl"; action = "<CMD>NotesFollowLink<CR>"; options.desc = "Follow link"; }
    { mode = "n"; key = "<leader>ni"; action = "<CMD>NotesTemplate<CR>"; options.desc = "Insert template"; }
    { mode = "n"; key = "<leader>ne"; action = "<CMD>NotesExport<CR>"; options.desc = "Export (pandoc)"; }
    { mode = "n"; key = "<leader>no"; action = "<CMD>NotesExportOpen<CR>"; options.desc = "Export & open in browser"; }
    { mode = "n"; key = "<leader>ng"; action = "<CMD>NotesGit<CR>"; options.desc = "LazyGit in notes dir"; }
    { mode = "n"; key = "<leader>nt"; action = "<CMD>NotesTags<CR>"; options.desc = "Search tags"; }
  ];
}

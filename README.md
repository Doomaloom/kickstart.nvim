# Minimal Neovim

Neovim 0.11.3+ with Gruvbox dark, relative line numbers, four-space indentation,
soft word wrapping that preserves indentation, and native LSP completion and diagnostics. Absolute line
numbers appear to the left of relative line numbers; the current line's
relative distance is `0`.

## Setup

Install Git, curl, unzip, Node/npm, Python, Go, and the .NET 10 SDK or newer.
Keep the runtimes and compilers your projects use installed as well.
The .NET runtime alone is insufficient for installing `csharp-ls`.

On this machine, the remaining prerequisite is `sudo pacman -S --needed dotnet-sdk`.
Then open Neovim and run `:MasonInstall csharp-language-server` if it has not
already been installed automatically.

Open `nvim` and let Lazy install plugins and Mason install language servers.
Use `:Lazy` and `:Mason` to inspect installation progress. Network access is
required on first setup. Restart Neovim after installations finish.

Enabled servers:

| Language | Server |
| --- | --- |
| Lua | lua_ls |
| JavaScript / TypeScript / JSX / TSX | ts_ls |
| HTML | html |
| CSS / SCSS / Less | cssls |
| Python | pyright |
| Go | gopls |
| C / C++ | clangd |
| C# | csharp_ls |

Open files within their projects so servers can discover project roots and
dependencies. C# needs a `.sln`, `.slnx`, or `.csproj`; Go uses `go.mod` or
`go.work`. For accurate C/C++ diagnostics, provide `compile_commands.json`
(for example, configure CMake with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`).
Python projects may need their interpreter selected through Pyright's project
configuration. Language-server formatting is available through
`:lua vim.lsp.buf.format()`; nothing formats automatically on save.

## Keys

| Key | Action |
| --- | --- |
| `Esc` (normal mode) | Clear search highlighting |
| `Ctrl-/` (normal / visual mode) | Toggle comments on the current line or selected lines |
| `Space e` | Toggle floating file tree, revealing the current file |
| `Space g b` | Toggle Git blame column beside the current file |
| `Space g h` | Open the current file's Git history in a popup |
| `Space g s` | Browse uncommitted files in a popup with diff previews |
| `Space g d` | Toggle an inline diff of the open file against the last commit |
| `gd` / `gD` | Definition / declaration |
| `gr` / `gi` | References / implementation |
| `K` | Hover documentation |
| `grn` | Rename symbol |
| `gra` | Code action |
| `Ctrl-Space` (insert mode) | Request completion |
| `Ctrl-n` / `Ctrl-p` | Select next / previous completion |
| `Ctrl-y` / `Ctrl-e` | Accept / dismiss completion |
| `[d` / `]d` | Previous / next diagnostic |
| `Ctrl-w d` | Show diagnostic details |

Completion also opens on server-defined trigger characters, such as `.`.
In the file tree, use `j` / `k` to move, `Enter` to open a file or expand a
directory, and `Esc` or `q` to close. `?` shows the available tree commands.
You can also open it with `:Neotree float reveal`.

All other editing and navigation use Neovim defaults.

## Git blame

In a Git-tracked file, press `Space g b` to open a blame column on the left.
It shows commit, author, date, and message information and scrolls with the
source file. Press the shortcut again to close it. In the blame column, `s`
opens the selected commit and `Enter` shows the available actions.
Wrapping is temporarily disabled while blame is open to keep lines aligned;
closing the column restores it. Git is the only external dependency.

## File history

Press `Space g h` in a Git-tracked file to browse its commits in a floating
Telescope window, with a diff preview for the selected commit. Type to filter
commits and use `Ctrl-n` / `Ctrl-p` to move through the list. `Enter` compares
the selected revision with the current file in a vertical diff split.
`Esc` closes the popup; in normal mode, `q` also closes it.

Close the historical split with `:q` and run `:diffoff` in the remaining window
to leave comparison mode. Browsing and comparing do not restore old content or
change Git's checkout. This shows committed Git history, not snapshots of
every save.

## Uncommitted changes

Press `Space g s` to open a searchable popup of the current repository's staged,
unstaged, and untracked files. New directories are expanded into individual
files. Select a file to preview its changes, then press `Enter` to open it.
Use `Ctrl-n` / `Ctrl-p` to navigate and `Esc` to close; in normal mode, `q`
also closes it. `Tab` stages or unstages the selected file.

Save your edits first: this view shows Git's changes on disk, not unsaved buffer
edits. Ignored files are excluded. No extra plugins or dependencies are needed.

## Inline diff

Press `Space g d` to toggle a unified diff directly in the current file.
Added and changed lines are highlighted; removed lines appear as virtual lines
beside their replacements. The comparison is against `HEAD`, so staged,
unstaged, and unsaved edits are included. Press the same shortcut to return
to normal editing. Viewing the diff does not change file contents or staging.

## Maintenance and recovery

Run `:checkhealth vim.lsp` and `:checkhealth mason` to diagnose server problems.
Use `:Lazy sync` to update plugins. The plugin lockfile is committed for
reproducible plugin versions; server versions are managed separately by Mason.

The previous configuration, including uncommitted edits and its lockfile,
is preserved in `.backups/20261017-233853/`. That directory is ignored by Git.
To restore it, copy its files back into this directory. Existing shared plugins
and Mason packages were retained; only the servers listed above are enabled.

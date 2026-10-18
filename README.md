# Minimal Neovim

Neovim 0.11.3+ with Gruvbox dark, relative line numbers, four-space indentation,
soft word wrapping, and native LSP completion and diagnostics.

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
| `Space e` | Toggle floating file tree, revealing the current file |
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

## Maintenance and recovery

Run `:checkhealth vim.lsp` and `:checkhealth mason` to diagnose server problems.
Use `:Lazy sync` to update plugins. The plugin lockfile is committed for
reproducible plugin versions; server versions are managed separately by Mason.

The previous configuration, including uncommitted edits and its lockfile,
is preserved in `.backups/20261017-233853/`. That directory is ignored by Git.
To restore it, copy its files back into this directory. Existing shared plugins
and Mason packages were retained; only the servers listed above are enabled.

-- Editing defaults.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 9
-- Absolute numbers on the left, relative distances on the right.
vim.opt.statuscolumn = "%s%C%{&nu && v:virtnum == 0 ? printf('%4d', v:lnum) : ''}" .. "%{&rnu && v:virtnum == 0 ? printf(' %3d ', v:relnum) : ' '}"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.textwidth = 0
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'popup' }
-- Keep Go's bundled filetype plugin from switching to literal tabs.
vim.g.go_recommended_style = false

-- Clear search highlighting with Escape.
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlighting' })

-- Toggle comments using Neovim's built-in commenting mappings.
-- Some terminals send Ctrl+/ as Ctrl+_.
for _, key in ipairs { '<C-/>', '<C-_>' } do
    vim.keymap.set('n', key, 'gcc', { remap = true, desc = 'Toggle line comment' })
    vim.keymap.set('x', key, 'gc', { remap = true, desc = 'Toggle selection comments' })
end

-- Bootstrap the plugin manager.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    local output = vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    }
    if vim.v.shell_error ~= 0 then
        error('Could not install lazy.nvim:\n' .. output)
    end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = 'Telescope',
        keys = {
            {
                '<Space>gs',
                function()
                    local actions = require 'telescope.actions'
                    require('telescope.builtin').git_status {
                        use_file_path = true,
                        expand_dir = true,
                        prompt_title = 'Uncommitted changes',
                        layout_strategy = 'horizontal',
                        layout_config = { width = 0.9, height = 0.85, preview_width = 0.6 },
                        attach_mappings = function(_, map)
                            map('i', '<Esc>', actions.close)
                            map('n', 'q', actions.close)
                            return true
                        end,
                    }
                end,
                desc = 'Browse uncommitted changes',
            },
            {
                '<Space>gh',
                function()
                    local actions = require 'telescope.actions'
                    require('telescope.builtin').git_bcommits {
                        use_file_path = true,
                        prompt_title = 'File history',
                        layout_strategy = 'horizontal',
                        layout_config = { width = 0.9, height = 0.85, preview_width = 0.6 },
                        attach_mappings = function(_, map)
                            actions.select_default:replace(actions.select_vertical)
                            map('i', '<Esc>', actions.close)
                            map('n', 'q', actions.close)
                            return true
                        end,
                    }
                end,
                desc = 'File Git history',
            },
        },
        opts = {},
    },
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = { signcolumn = false },
        keys = {
            {
                '<Space>gd',
                function()
                    require('gitsigns').diffthis('HEAD', { unified = true })
                end,
                desc = 'Toggle inline diff against HEAD',
            },
            {
                '<Space>gb',
                function()
                    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype == 'gitsigns-blame' then
                            vim.api.nvim_win_close(win, true)
                            return
                        end
                    end
                    require('gitsigns').blame()
                end,
                desc = 'Toggle Git blame column',
            },
        },
    },
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        cmd = 'Neotree',
        dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
        keys = {
            { '<Space>e', '<Cmd>Neotree toggle float reveal<CR>', desc = 'Toggle floating file tree' },
        },
        opts = {
            sources = { 'filesystem' },
            enable_git_status = false,
            enable_diagnostics = false,
            window = {
                position = 'float',
                mappings = { ['<esc>'] = 'close_window' },
            },
        },
    },
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'gruvbox'
        end,
    },
    {
        'saghen/blink.cmp',
        version = '1.*',
        opts = {
            keymap = {
                preset = 'super-tab',
                ['<C-y>'] = { 'select_and_accept', 'fallback' },
            },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 250 },
                trigger = { show_in_snippet = false },
            },
            sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
            signature = { enabled = true },
            cmdline = { enabled = false },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'saghen/blink.cmp',
            { 'mason-org/mason.nvim', opts = {} },
            'mason-org/mason-lspconfig.nvim',
        },
        config = function()
            vim.lsp.config('*', {
                capabilities = require('blink.cmp').get_lsp_capabilities(),
            })

            local servers = {
                'lua_ls',
                'ts_ls',
                'html',
                'cssls',
                'pyright',
                'gopls',
                'clangd',
                'csharp_ls',
            }

            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = { globals = { 'vim' } },
                        workspace = {
                            checkThirdParty = false,
                            library = { vim.env.VIMRUNTIME },
                        },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('minimal-lsp', { clear = true }),
                callback = function(event)
                    local function map(keys, action, desc)
                        vim.keymap.set('n', keys, action, { buffer = event.buf, desc = desc })
                    end
                    map('gd', vim.lsp.buf.definition, 'Go to definition')
                    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
                    map('gr', vim.lsp.buf.references, 'Find references')
                    map('gi', vim.lsp.buf.implementation, 'Go to implementation')
                    map('K', vim.lsp.buf.hover, 'Hover documentation')
                    map('grn', vim.lsp.buf.rename, 'Rename symbol')
                    map('gra', vim.lsp.buf.code_action, 'Code action')
                end,
            })

            require('mason-lspconfig').setup {
                ensure_installed = servers,
                automatic_enable = servers,
            }
        end,
    },
}, {
    checker = { enabled = false },
    change_detection = { notify = false },
})

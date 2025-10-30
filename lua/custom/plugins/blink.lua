return {
  {
    'saghen/blink.cmp',
    dependencies = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
    config = function()
      local blink = require 'blink.cmp'

      blink.setup {
        -- Enable LSP
        sources = {
          default = { 'lsp', 'path', 'buffer' },
        },

        -- Keymaps for completion
        keymap = {
          preset = 'default',
          ['<CR>'] = { 'accept', 'fallback' },
          ['<Tab>'] = {
            'snippet_forward',
            function()
              return require('sidekick').nes_jump_or_aply()
            end,
            function()
              return vim.lsp.inline_completion.get()
            end,
            'fallback',
          },
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
        },
      }

      -- Mason ensures servers are installed
      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = { 'pyright', 'clangd', 'lua_ls' },
        handlers = {
          function(server)
            require('lspconfig')[server].setup {}
          end,
        },
      }
    end,
  },
}

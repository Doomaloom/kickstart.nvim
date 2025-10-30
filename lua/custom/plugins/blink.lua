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

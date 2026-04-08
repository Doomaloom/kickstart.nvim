-- ~/.config/nvim/lua/plugins/git.lua
return {
  { 'tpope/vim-fugitive' },

  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  {
    'akinsho/git-conflict.nvim',
    version = '*',
    config = function()
      require('git-conflict').setup()
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {},
  },
}

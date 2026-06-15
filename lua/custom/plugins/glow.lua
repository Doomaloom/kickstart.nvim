return {
  {
    'ellisonleao/glow.nvim',
    config = function()
      require('glow').setup {
        install_path = '~/.local/bin',
        border = 'shadow',
        style = 'dark',
        pager = false,
      }
    end,
    cmd = { 'Glow' },
  },
}

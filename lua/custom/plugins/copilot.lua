return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',

  opts = {
    panel = { enabled = false },

    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,

      keymap = {
        accept = '<M-l>', -- accept full suggestion
        accept_word = '<M-w>', -- accept next word
        accept_line = '<M-;>', -- accept next line

        next = '<M-]>', -- next suggestion
        prev = '<M-[>', -- previous suggestion
        dismiss = '<C-]>', -- dismiss suggestion
      },
    },

    filetypes = {
      markdown = true,
      help = false,
      gitcommit = true,
      yaml = true,
    },
  },

  config = function(_, opts)
    require('copilot').setup(opts)
  end,
}
